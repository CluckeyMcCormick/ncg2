tool
extends Spatial

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

const BASE_HEIGHT = 3

const MAX_ROLLS = 10

# The material we'll use to make this building.
export(Material) var building_material setget set_building_material

# The length (in total number of cells) of each side of the building. It's a
# rectangular prism, so we measure the length on each axis.
export(int) var footprint_len_x = 8 setget set_length_x
export(int) var footprint_len_z = 8 setget set_length_z

# What's the standard deviation for the rotation of any given building on a
# sled? This is a "deviation" in the terms of a Gaussian Distribution, meaning
# that 68% will be within plus-or-minus this value.
export(float) var rotation_deviation = 45

# Ditto as above, but for the length on y of each of our two components
export(int) var tower_len_y = 14 setget set_tower_length_y

# Ditto as above, but for the length on y of each of our two components
export(int) var lights = 2 setget set_lights

# Do we auto-build on entering the scene?
export(bool) var auto_build = false setget set_auto_build

var _light_arr = []

# Our random number generator
var RNGENNIE = RandomNumberGenerator.new()

# --------------------------------------------------------
#
# Running Functions
#
# --------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready():
    RNGENNIE.randomize()
    
    if auto_build:
        make_building()

# --------------------------------------------------------
#
# Setters and Getters
#
# --------------------------------------------------------
func set_building_material(new_building_material):
    building_material = new_building_material
    if Engine.editor_hint and auto_build:
        make_building()

func set_length_x(new_length):
    footprint_len_x = new_length
    if Engine.editor_hint and auto_build:
        make_building()
    
func set_length_z(new_length):
    footprint_len_z = new_length
    if Engine.editor_hint and auto_build:
        make_building()

func set_tower_length_y(new_length):
    tower_len_y = new_length
    if Engine.editor_hint and auto_build:
        make_building()

func set_lights(new_lights):
    lights = new_lights
    if Engine.editor_hint and auto_build:
        make_building()

func set_auto_build(new_autobuild):
    auto_build = new_autobuild
    if Engine.editor_hint and auto_build:
        make_building()

# --------------------------------------------------------
#
# Build Functions
#
# --------------------------------------------------------
func make_building():
    # If we don't have the building nodes for whatever reason, back out
    if not self.has_node("Base") or not self.has_node("MainTower"):
        return
    # Clean up our lights
    for light in _light_arr:
        self.remove_child(light)
        light.queue_free()
    _light_arr.clear()

    # Okay, pick a random rotation.
    var building_rotation = RNGENNIE.randfn(0.0, rotation_deviation)
    
    var light
    
    var roll_count = 0
    
    # What's the ACTUAL footprint of the rotated building going to be? Notice
    # that we're prematurely shrinking the building lengths, down to a minimum
    # of 1
    var new_len_x = max(footprint_len_x - 1, 1)
    var new_len_z = max(footprint_len_z - 1, 1)
    
    # We'll use these to determine if we need to shrink a side and which side to
    # shrink.
    var in_print
    var parity = 0
    
    # Generate vector2 points according to the new lengths
    var a = Vector2(-new_len_x / 2, -new_len_z / 2)
    var b = Vector2( new_len_x / 2,  new_len_z / 2)
    var c = Vector2(-new_len_x / 2,  new_len_z / 2)
    var d = Vector2( new_len_x / 2, -new_len_z / 2)
    # We'll stick the points in here
    var points = []
    
    # Alright, figure out how these points look when rotated
    a = a.rotated(deg2rad(building_rotation))
    b = b.rotated(deg2rad(building_rotation))
    c = c.rotated(deg2rad(building_rotation))
    d = d.rotated(deg2rad(building_rotation))
    
    # Ensure these points are in the base footprint.
    in_print = in_footprint(a) and in_footprint(b) and in_footprint(b) \
           and in_footprint(b)
    
    # While the building is not in the footprint...
    while not in_print and roll_count < MAX_ROLLS:
        # Alternate shrinking the x and z lengths
        if parity % 2 == 0:
            new_len_x -= 1
        else:
            new_len_z -= 1
        parity += 1
        
        # Create our new points
        a = Vector2(-new_len_x / 2, -new_len_z / 2)
        b = Vector2( new_len_x / 2,  new_len_z / 2)
        c = Vector2(-new_len_x / 2,  new_len_z / 2)
        d = Vector2( new_len_x / 2, -new_len_z / 2)
        
        # Rotate them
        a = a.rotated(deg2rad(building_rotation))
        b = b.rotated(deg2rad(building_rotation))
        c = c.rotated(deg2rad(building_rotation))
        d = d.rotated(deg2rad(building_rotation))
        
        # Check we're in the footprint
        in_print = in_footprint(a) and in_footprint(b) and in_footprint(b) \
           and in_footprint(b)
        
        roll_count += 1
    
    # If we capped out on the number of rolls we allowed, we'll just do default
    # to a non-rotated building.
    if roll_count >= MAX_ROLLS:
        new_len_x = max(footprint_len_x - 1, 1)
        new_len_z = max(footprint_len_z - 1, 1)
        
        # Generate vector2 points according to the new lengths
        a = Vector2(-new_len_x / 2, -new_len_z / 2)
        b = Vector2( new_len_x / 2,  new_len_z / 2)
        c = Vector2(-new_len_x / 2,  new_len_z / 2)
        d = Vector2( new_len_x / 2, -new_len_z / 2)
    else:
        # Find the TRUE A, B, C, and D values
        points = [a, b, c, d]
        a = true_a(points)
        b = true_b(points)
        c = true_c(points)
        d = true_d(points)
    
    if not in_box(a, b, c, d, Vector2(footprint_len_x, footprint_len_z)):
        light = OmniLight.new()
        light.omni_range = 10
        light.light_color = Color("002459")
        light.shadow_enabled = true
        self.add_child(light)
        light.translation = Vector3(
            footprint_len_x * GlobalRef.WINDOW_UV_SIZE,
            0,
            footprint_len_z * GlobalRef.WINDOW_UV_SIZE
        )
        self._light_arr.append(light)
        
        pass
    
    # Otherwise, pass the materials down to the buildings
    $Base.building_material = building_material
    $MainTower.building_material = building_material
    
    # Pass down the values to the base
    $Base.len_x = new_len_x
    $Base.len_z = new_len_z
    $Base.len_y = BASE_HEIGHT
    
    # If this tower is so short that it's all base, just set the base to the
    # tower height.
    if tower_len_y < BASE_HEIGHT:
        $Base.len_y = tower_len_y
    
    # Now, pass the values to the main tower
    $MainTower.len_x = new_len_x
    $MainTower.len_z = new_len_z
    # using max will catch instances where tower_len_y < BASE_HEIGHT
    $MainTower.len_y = max(tower_len_y - BASE_HEIGHT, 0)
    
    # Now, move the tower up appropriately
    $MainTower.translation.y = GlobalRef.WINDOW_UV_SIZE * BASE_HEIGHT
    
    # Now build both buildings
    $Base.make_building()
    $MainTower.make_building()
    
    # Now we need to adjust the visibility modifier. To do that, we need to
    # calculate the effective length on each axis.
    var eff_x = new_len_x * GlobalRef.WINDOW_UV_SIZE
    var eff_y = tower_len_y * GlobalRef.WINDOW_UV_SIZE
    var eff_z = new_len_z * GlobalRef.WINDOW_UV_SIZE
    
    $VisibilityNotifier.aabb.position.x = -eff_x / 2
    $VisibilityNotifier.aabb.position.y = 0
    $VisibilityNotifier.aabb.position.z = -eff_z / 2

    $VisibilityNotifier.aabb.size.x = eff_x
    $VisibilityNotifier.aabb.size.y = eff_y
    $VisibilityNotifier.aabb.size.z = eff_z
    
    self.rotation_degrees.y = building_rotation

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
