extends Spatial

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")
# Get the MaterialColorControl
onready var mcc = get_node("/root/MaterialColorControl")

# A building is composed of two parts: an windowless/untextured base, and a
# windowed component. The two parts of the building together make up the whole
# of the building's height. The base will be UP TO this height; everything above
# this will be the textured/windowed component. If the building is
# less-than-or-equal-to this height, then the whole of the building will be the
# base.
const BASE_HEIGHT = 3

# In order to add more variation to the buildings, we randomly rotate the
# tower and then shrink it to fit in our footprint. However, we don't want to do
# that infinitely - how many times do we do that before we just give up and
# default to a non-rotation?
const MAX_ROLLS = 25 #10

# What's the minimum thinness (in windows) we'll allow for one side of a
# building? This will (probably) stop us from getting weird ultra-thin
# buildings.
const MIN_THIN = 2

# We include the radius of the lights when calculating the building's Visibility
# AABB (which determines if we're on screen or not). However, it's been observed
# that sometimes the building loads in but the lights won't load until later. To
# get around that, we'll use this scalar to increase the light radius included
# in the AABB - that means the buildings will load in sooner, and so too will
# their lights.
const LIGHT_SCALAR = 2

# TODO: Figure out decorations (distribution, selection, etc.)
# TODO: Decoration, On-Wall Billboards
# TODO: Decoration, Hanging Billboards
# TODO: Decoration, Rooftop Billboards
# TODO: Decoration, Box Billboards
# TODO: Decoration, AC Box
# TODO: Decoration, Antennae

# The length (in total number of cells) of each side of the building. It's a
# rectangular prism, so we measure the length on each axis.
export(int) var footprint_len_x = 8
export(int) var footprint_len_z = 8

# What's the standard deviation for the rotation of any given building on a
# sled? This is a "deviation" in the terms of a Gaussian Distribution, meaning
# that 68% will be within plus-or-minus this value.
export(float) var rotation_deviation = 45

# Ditto as above, but for the length on y of each of our two components
export(int) var tower_len_y = 14

# Do we auto-build on entering the scene?
export(bool) var auto_build = false

# The footprint building will automatically select one of the three MCC
# materials - however, you can provide it with an override material if you have
# something specific in mind. This takes effect in the make_building() method,
# so you'll either need to set this when the building enters the scene OR you'll
# need to call make_building() again.
# TODO: Use Override Material on the Base & MainTower whenever it is set. If the
# Override Material is unset, it should fall back to an mcc material.
export(Material) var override_material = null

# Signal emitted when our blueprint-construction thread is completed. Emits the
# building that got completed.
signal blueprint_completed(building)

# Signal emitted when this building enters the screen - basically an echo of the
# VisibilityNotifier's screen_entered signal. This is emitted AFTER we make
# adjustments for being visible.
signal screen_entered(building)
# Ditton, but for when the building exits the screen. As before, this is emitted
# AFTER we make adjustments for not being visible.
signal screen_exited(building)

# The blueprint variables. Our construction is divided into two phases: first,
# we do the algorithmically complex heavy work of designing the building. We
# store the results in the "blueprint" variables - the length-per-side on x and
# z, the rotation, and the information on the lights.
var blp_len_x
var blp_len_z
var blp_rotation
var blp_lights = []

# The thread that we'e using to construct the blueprints.
var build_thread = null

# Our random number generator
var RNGENNIE = RandomNumberGenerator.new()

# The random seed for this building. We reassert this seed before any
# random-reliant functions.
var _seed = 0

# Do we rotate the building in the footprint? Since we shrink rotated buildings
# to fit in the footprint, this can result in thinner buildings but ALSO results
# in a much more dynamic looking city.
var rotation_enabled = true

# --------------------------------------------------------
#
# Running Functions
#
# --------------------------------------------------------
func _init(in_seed = ""):
    # If we didn't get a seed...
    if in_seed == "":
        # Just use a time-based seed
        RNGENNIE.randomize()
    # Otherwise...
    else:
        # Translate the seed into an actual seed using a hash
        RNGENNIE.seed = hash(in_seed)
    
    # Capture the seed so we can reuse it whenever we need to.
    _seed = RNGENNIE.seed

# Called when the node enters the scene tree for the first time.
func _ready():
    # If we're auto-building...
    if auto_build:
        # Start the make-thread!
        start_make_thread()

func _physics_process(delta):
    if build_thread != null and not build_thread.is_alive():
        build_thread.wait_to_finish()
        build_thread = null
        emit_signal("blueprint_completed", self)

func _on_VisibilityNotifier_screen_entered():
    $Building.visible = true
    $FxManager.visible = true
    
    # Emit!
    emit_signal("screen_entered", self)

func _on_VisibilityNotifier_screen_exited():
    $Building.visible = false
    $FxManager.visible = false
    
    # Emit!
    emit_signal("screen_exited", self)

# --------------------------------------------------------
#
# Build Functions
#
# --------------------------------------------------------
func start_make_thread():
    # If we have a thread in progress, skip this!
    if build_thread != null:
        return
    
    # Launch the blueprint-crafting thread
    build_thread = Thread.new()
    build_thread.start(self, "make_blueprint")

func make_complete():
    make_blueprint()
    make_building()

func make_blueprint():
    # We'll use these to determine if we need to shrink a side and which side to
    # shrink.
    var in_print 

    # How many times have we shrank the size of this building-blueprint due to
    # the rotation?
    var roll_count = 0
    
    # These are the four points of the building-blueprint's "square"
    var a
    var b
    var c
    var d

    # We'll stick the points in here
    var points = []
    
    # Reassert the seed of our random number generator
    RNGENNIE.seed = _seed
    
    # Clear our lights
    blp_lights.clear()
    
    # Okay, pick a random rotation.
    if rotation_enabled:
        blp_rotation = clamp(
            RNGENNIE.randfn(0.0, rotation_deviation), -45, 45
        )
    else:
        blp_rotation = 0
        
    # What's the ACTUAL footprint of the rotated building going to be? Notice
    # that we're prematurely shrinking the building lengths, down to a minimum
    # of 1
    blp_len_x = max(footprint_len_x - 1, 1)
    blp_len_z = max(footprint_len_z - 1, 1)
    
    # Generate vector2 points according to the new lengths
    a = Vector2(-blp_len_x / 2, -blp_len_z / 2)
    b = Vector2( blp_len_x / 2,  blp_len_z / 2)
    c = Vector2(-blp_len_x / 2,  blp_len_z / 2)
    d = Vector2( blp_len_x / 2, -blp_len_z / 2)
    
    # Alright, figure out how these points look when rotated
    a = a.rotated(deg2rad(blp_rotation))
    b = b.rotated(deg2rad(blp_rotation))
    c = c.rotated(deg2rad(blp_rotation))
    d = d.rotated(deg2rad(blp_rotation))
    
    # Ensure these points are in the base footprint.
    in_print = in_footprint(a) and in_footprint(b) and in_footprint(b) \
           and in_footprint(b)
    
    # While the building is not in the footprint...
    while not in_print and roll_count < MAX_ROLLS:
        # Alternate shrinking the x and z lengths
        if roll_count % 2 == 0:
            blp_len_x -= 1
        else:
            blp_len_z -= 1
        
        # If one of our sides is less than our minimum thinness, then increment
        # by MAX_ROLLS and break. This will reset the size and rotation of the
        # building.
        if min(blp_len_x, blp_len_z) < MIN_THIN:
            roll_count += MAX_ROLLS
            break
        
        # Create our new points
        a = Vector2(-blp_len_x / 2, -blp_len_z / 2)
        b = Vector2( blp_len_x / 2,  blp_len_z / 2)
        c = Vector2(-blp_len_x / 2,  blp_len_z / 2)
        d = Vector2( blp_len_x / 2, -blp_len_z / 2)
        
        # Rotate them
        a = a.rotated(deg2rad(blp_rotation))
        b = b.rotated(deg2rad(blp_rotation))
        c = c.rotated(deg2rad(blp_rotation))
        d = d.rotated(deg2rad(blp_rotation))
        
        # Check we're in the footprint
        in_print = in_footprint(a) and in_footprint(b) and in_footprint(c) \
           and in_footprint(d)
        
        # Increment the rolls we've done
        roll_count += 1
    
    # If we capped out on the number of rolls we allowed, we'll just do default
    # to a non-rotated building.
    if roll_count >= MAX_ROLLS:
        # Default the size
        blp_len_x = max(footprint_len_x - 1, 1)
        blp_len_z = max(footprint_len_z - 1, 1)
        
        # Default the rotation
        blp_rotation = 0
        
        # Generate vector2 points according to the new lengths
        a = Vector2(-blp_len_x / 2, -blp_len_z / 2)
        b = Vector2( blp_len_x / 2,  blp_len_z / 2)
        c = Vector2(-blp_len_x / 2,  blp_len_z / 2)
        d = Vector2( blp_len_x / 2, -blp_len_z / 2)
    else:
        # Find the TRUE A, B, C, and D values
        points = [a, b, c, d]
        a = true_a(points)
        b = true_b(points)
        c = true_c(points)
        d = true_d(points)
    
    # We have a light at each one of the corners
    var light_positions = [
        Vector2( footprint_len_x,  footprint_len_z),
        Vector2(-footprint_len_x,  footprint_len_z),
        Vector2( footprint_len_x, -footprint_len_z),
        Vector2(-footprint_len_x, -footprint_len_z)
    ]
    
    # For each light...
    for pos in light_positions:
        # If it's clipping with our rotated building, skip it!
        if in_box(a, b, c, d, pos):
            continue

        # Otherwise, we're gonna stick a blueprint light. The blueprint light is
        # actually an array, composed of...
        blp_lights.append([
            # A size, measured in windows. We want the light to climb part of
            # the building, so we'll go between 1/4 and 3/4 of the building's
            # total height.
            RNGENNIE.randi_range(
                round(tower_len_y * .25), round(tower_len_y * .75)
            ),
            # A group designation
            RNGENNIE.randi() % 4,
            # The actual position
            pos
        ])

func make_building():
    var chosen_mat
    
    # If we don't have the building nodes for whatever reason, back out
    if not self.has_node("Building/Base") or not self.has_node("Building/MainTower"):
        return
    
    # Clear up the lights
    for light in $FxManager.get_children():
        $FxManager.remove_child(light)
        light.queue_free()
    
    match RNGENNIE.randi_range(1, 3):
        1:
            chosen_mat = mcc.mat_a
        2:
            chosen_mat = mcc.mat_b
        3:
            chosen_mat = mcc.mat_c
        _:
            pass
    if override_material:
        $Building/Base.building_material = override_material
        $Building/MainTower.building_material = override_material
    else:
        $Building/Base.building_material = chosen_mat
        $Building/MainTower.building_material = chosen_mat
    
    # Pass down the values to the base
    $Building/Base.len_x = blp_len_x
    $Building/Base.len_z = blp_len_z
    $Building/Base.len_y = BASE_HEIGHT
    
    # If this tower is so short that it's all base, just set the base to the
    # tower height.
    if tower_len_y < BASE_HEIGHT:
        $Building/Base.len_y = tower_len_y
    
    # Now, pass the values to the main tower
    $Building/MainTower.len_x = blp_len_x
    $Building/MainTower.len_z = blp_len_z
    # using max will catch instances where tower_len_y < BASE_HEIGHT
    $Building/MainTower.len_y = max(tower_len_y - BASE_HEIGHT, 0)
    
    # Now, move the tower up appropriately
    $Building/MainTower.translation.y = GlobalRef.WINDOW_UV_SIZE * BASE_HEIGHT
    
    # Now build both buildings
    $Building/Base.make_building()
    $Building/MainTower.make_building()
    
    # Now we need to adjust the visibility modifier. To do that, we need to
    # calculate the effective length on each axis.
    var eff_x = blp_len_x * GlobalRef.WINDOW_UV_SIZE
    var eff_y = tower_len_y * GlobalRef.WINDOW_UV_SIZE
    var eff_z = blp_len_z * GlobalRef.WINDOW_UV_SIZE
    
    var old_x = eff_x
    var old_z = eff_z
    
    # Calculate the effective scalar for the omni-light. This is a horrendously
    # lazy way of doing it, but it works for what I need.
    var eff_scalar = abs( (scale.x + scale.y + scale.z) / 2 )
    
    for light_arr in blp_lights:
        var light = OmniLight.new()
        light.omni_range = light_arr[0] * GlobalRef.WINDOW_UV_SIZE
        match light_arr[1]:
            0:
                light.light_color = mcc.profile_dict["lights_one_color"]
                light.visible = mcc.profile_dict["lights_one_visible"]
                light.add_to_group(GlobalRef.light_group_one)
            1:
                light.light_color = mcc.profile_dict["lights_two_color"]
                light.visible = mcc.profile_dict["lights_two_visible"]
                light.add_to_group(GlobalRef.light_group_two)
            2:
                light.light_color = mcc.profile_dict["lights_three_color"]
                light.visible = mcc.profile_dict["lights_three_visible"]
                light.add_to_group(GlobalRef.light_group_three)
            3:
                light.light_color = mcc.profile_dict["lights_four_color"]
                light.visible = mcc.profile_dict["lights_four_visible"]
                light.add_to_group(GlobalRef.light_group_four)
        $FxManager.add_child(light)
        light.translation = Vector3(
            light_arr[2].x * GlobalRef.WINDOW_UV_SIZE,
            0,
            light_arr[2].y * GlobalRef.WINDOW_UV_SIZE
        )
        
        # We're going to do this as lazily as possible: Let's say, in this
        # diagram, B & Y are the edges of the building. A is the farthest point
        # reached by a light at B. Z is the farthest point reached by a light at
        # Z. We can observe:
        #                       A-------B#####Y-------Z
        # Basically, we need to update the effective x and z such that they
        # encompass A through Z. That means doubling the omni_radius and adding
        # it onto the length of the appropriate side of the footprint.
        eff_x = max(
            (blp_len_x * GlobalRef.WINDOW_UV_SIZE) + (light.omni_range * 2 * LIGHT_SCALAR), 
            eff_x
        )
        eff_z = max(
            (blp_len_z * GlobalRef.WINDOW_UV_SIZE) + (light.omni_range * 2 * LIGHT_SCALAR), 
            eff_z
        )
        
        # Now, after all that, apply the effective scalar. Our AABB will scale,
        # but not the light's range.
        light.omni_range *= eff_scalar
    
    #
    # Beacons
    #
    $Building/BeaconA.translation.x = old_x / 2.0
    $Building/BeaconA.translation.z = old_z / 2.0

    $Building/BeaconB.translation.x = old_x / 2.0
    $Building/BeaconB.translation.z = -old_z / 2.0

    $Building/BeaconC.translation.x = -old_x / 2.0
    $Building/BeaconC.translation.z = -old_z / 2.0

    $Building/BeaconD.translation.x = -old_x / 2.0
    $Building/BeaconD.translation.z = old_z / 2.0
    
    $Building/BeaconA.curr_beacon_height = tower_len_y
    $Building/BeaconB.curr_beacon_height = tower_len_y
    $Building/BeaconC.curr_beacon_height = tower_len_y
    $Building/BeaconD.curr_beacon_height = tower_len_y
    
    # Roll the kind of beacon we get
    match RNGENNIE.randi() % 3:
        0:
            $Building/BeaconA.type = $Building/BeaconA.BeaconType.A
            $Building/BeaconB.type = $Building/BeaconA.BeaconType.A
            $Building/BeaconC.type = $Building/BeaconA.BeaconType.A
            $Building/BeaconD.type = $Building/BeaconA.BeaconType.A
        1:
            $Building/BeaconA.type = $Building/BeaconA.BeaconType.B
            $Building/BeaconB.type = $Building/BeaconA.BeaconType.B
            $Building/BeaconC.type = $Building/BeaconA.BeaconType.B
            $Building/BeaconD.type = $Building/BeaconA.BeaconType.B
        2:
            $Building/BeaconA.type = $Building/BeaconA.BeaconType.C
            $Building/BeaconB.type = $Building/BeaconA.BeaconType.C
            $Building/BeaconC.type = $Building/BeaconA.BeaconType.C
            $Building/BeaconD.type = $Building/BeaconA.BeaconType.C
    
    #
    # AABB
    #
    $VisibilityNotifier.aabb.position.x = -eff_x / 2
    $VisibilityNotifier.aabb.position.y = 0
    $VisibilityNotifier.aabb.position.z = -eff_z / 2

    $VisibilityNotifier.aabb.size.x = eff_x
    $VisibilityNotifier.aabb.size.y = eff_y
    $VisibilityNotifier.aabb.size.z = eff_z
    
    #
    # Building
    #
    $Building.rotation_degrees.y = blp_rotation

# --------------------------------------------------------
#
# Utility/Calculation Functions
#
# --------------------------------------------------------
func in_footprint(var point):
    if point.x < -footprint_len_x / 2 or footprint_len_x / 2 < point.x:
        return false
    
    if point.y < -footprint_len_z / 2 or footprint_len_z / 2 < point.y:
        return false
    
    return true

func closest_to(var points_to_check, var target_point : Vector2):
    var closest_dist = INF
    var closest
    
    for point in points_to_check:
        if target_point.distance_to(point) < closest_dist:
            closest = point
            closest_dist = target_point.distance_to(point)
    
    return closest

# Finds point closest to -INF, -INF
func true_a(var points):
    return closest_to(points, Vector2(-100, -100))

# Finds point closest to INF, INF
func true_b(var points):
    return closest_to(points, Vector2(100, 100))

# Finds point closest to -INF, INF
func true_c(var points):
    return closest_to(points, Vector2(-100, 100))

# Finds point closest to INF, -INF
func true_d(var points):
    return closest_to(points, Vector2(100, -100))

func in_box(var a, var b, var c, var d, var point):
    # Now, we'll assume that the points passed in comply to these rules:
    #   * a is closest point to -INF, -INF    * b is closest point to INF, INF
    #   * c is closest point to -INF,  INF    * b is closest point to INF, -INF
    return in_triangle(a, b, c, point) or in_triangle(a, b, d, point)

func in_triangle(var a, var b, var c, var point):     
    var v0 = c - a;
    var v1 = b - a;
    var v2 = point - a;

    var dot00 = v0.dot(v0)
    var dot01 = v0.dot(v1)
    var dot02 = v0.dot(v2)
    var dot11 = v1.dot(v1)
    var dot12 = v1.dot(v2)

    var invDenom = pow(dot00 * dot11 - dot01 * dot01, -1);
    var u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    var v = (dot00 * dot12 - dot01 * dot02) * invDenom;
    
    # If the point was in the triangle, this statement will return true.
    # Otherwise, it'll return false!
    return u >= 0 && v >= 0 && (u + v) < 1
