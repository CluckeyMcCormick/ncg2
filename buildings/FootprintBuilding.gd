tool
extends Spatial

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

const BASE_HEIGHT = 3

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

# Do we auto-build on entering the scene?
export(bool) var auto_build = true setget set_auto_build

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

    # Okay, pick a random rotation.
    var building_rotation = RNGENNIE.randfn(0.0, rotation_deviation)
    
    var new_len_x = footprint_len_x
    var new_len_z = footprint_len_z
    
    var in_print
    var parity = 0
    
    var a = Vector3(-new_len_x / 2, 0, -new_len_z / 2)
    var b = Vector3( new_len_x / 2, 0,  new_len_z / 2)
    var c = Vector3(-new_len_x / 2, 0,  new_len_z / 2)
    var d = Vector3( new_len_x / 2, 0, -new_len_z / 2)
    
    a = a.rotated(Vector3.UP, deg2rad(building_rotation))
    b = b.rotated(Vector3.UP, deg2rad(building_rotation))
    c = c.rotated(Vector3.UP, deg2rad(building_rotation))
    d = d.rotated(Vector3.UP, deg2rad(building_rotation))
    
    in_print = in_footprint(a) and in_footprint(b) and in_footprint(b) \
           and in_footprint(b)
    
    while not in_print:
        
        if parity % 2 == 0:
            new_len_x -= 1
        else:
            new_len_z -= 1
        
        parity += 1
        
        a = Vector3(-new_len_x / 2, 0, -new_len_z / 2)
        b = Vector3( new_len_x / 2, 0,  new_len_z / 2)
        c = Vector3(-new_len_x / 2, 0,  new_len_z / 2)
        d = Vector3( new_len_x / 2, 0, -new_len_z / 2)
        
        a = a.rotated(Vector3.UP, deg2rad(building_rotation))
        b = b.rotated(Vector3.UP, deg2rad(building_rotation))
        c = c.rotated(Vector3.UP, deg2rad(building_rotation))
        d = d.rotated(Vector3.UP, deg2rad(building_rotation))

        in_print = in_footprint(a) and in_footprint(b) and in_footprint(b) \
           and in_footprint(b)
    
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
    # Otherwise
    
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

    if point.z < -footprint_len_z / 2 or footprint_len_z / 2 < point.z:
        return false
    
    return true
