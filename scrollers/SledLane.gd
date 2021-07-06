tool
extends Spatial

# Load the scroll-sled script
const ScrollSled = preload("res://util/GlobalRef.gd")
# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# Load the scroll-sled scene
const scroll_sled_scene = preload("res://scrollers/ScrollSled.tscn")

# What's the minimum length for a building in this lane on x?
export(int) var width_min = 5 setget set_width_min
# What's the maximum length for a building in this lane on x?
export(int) var width_max = 9 setget set_width_max

# What's the minimum length for a building in this lane on z?
export(int) var depth_min = 4 setget set_depth_min
# What's the maximum length for a building in this lane on z?
export(int) var depth_max = 8 setget set_depth_max

# What's the minimum length for a building's base, in this lane, on y?
export(int) var base_height_min = 2
# What's the maximum length for a building's base, in this lane, on y?
export(int) var base_height_max = 4

# What's the minimum length for a building in this lane on y?
export(int) var tower_height_min = 4
# What's the maximum length for a building in this lane on y?
export(int) var tower_height_max = 8

# What's the standard deviation for the rotation of any given building on a
# sled? This is a "deviation" in the terms of a Gaussian Distribution, meaning
# that 68% will be within plus-or-minus this value.
export(float) var rotation_deviation = 45

# What's the last sled we made?
var last_sled = null

# Our random number generator
var RNGENNIE

# Called when the node enters the scene tree for the first time.
func _ready():
    # Create a random number generator
    RNGENNIE = RandomNumberGenerator.new()
    
    # If we're in the editor, back out!!!
    if Engine.editor_hint:
        return
        
    make_sled()

func _process(delta):
    # If we're in the editor, back out!!!
    if Engine.editor_hint:
        return
    
    # If we don't have a last sled, back out.
    if last_sled == null:
        return
    
    # Otherwise, if the local translation of the sled, on X, exceeds or meets
    # the potential max x-length of the sled...
    if abs(last_sled.translation.x) >= last_sled.max_poss_x_len:
        # Then make a new sled
        make_sled()

# --------------------------------------------------------
#
# Setters and Getters
#
# --------------------------------------------------------
func get_random_int(min_val, max_val):
    return (randi() % (max_val - min_val)) + min_val

func set_width_min(new_width_min):
    width_min = new_width_min
    if Engine.editor_hint:
        make_debug()
    
func set_width_max(new_width_max):
    width_max = new_width_max
    if Engine.editor_hint:
        make_debug()

func set_depth_min(new_depth_min):
    depth_min = new_depth_min
    if Engine.editor_hint:
        make_debug()
    
func set_depth_max(new_depth_max):
    depth_max = new_depth_max
    if Engine.editor_hint:
        make_debug()

# --------------------------------------------------------
#
# Build Functions
#
# --------------------------------------------------------
func make_sled():
    # Create a new sled
    var new_sled = scroll_sled_scene.instance()
    
    # Roll the different lengths
    var len_x = get_random_int(width_min, width_max)
    var len_z = get_random_int(depth_min, depth_max)
    var base_height = get_random_int(base_height_min, base_height_max)
    var tower_height = get_random_int(tower_height_min, tower_height_max)
    
    # Pass those different lengths down to the FSB
    new_sled.set_building_size(len_x, len_z, base_height, tower_height)
    
    # Rotate the building to a random (but gaussian-distributed) direction
    new_sled.set_building_y_rotation(RNGENNIE.randfn(0.0, rotation_deviation))
    
    # Stick the sled in the tree
    self.add_child(new_sled)
    # Force the sled's FSB to build
    new_sled.make_building()
    
    # This is now the last sled 
    last_sled = new_sled

func make_debug():
    # If we don't have a mesh to mess with, back out.
    if not self.has_node("DebugMesh"):
        return
    
    var width = (width_max * GlobalRef.WINDOW_UV_SIZE) * 10
    var depth = (depth_max * GlobalRef.WINDOW_UV_SIZE) * 10
    var c_squared = sqrt(pow(width, 2) + pow(depth, 2))
    var maxed = max( max(width, depth), c_squared )
    
    $DebugMesh.mesh = CubeMesh.new()
    $DebugMesh.mesh.set_size( Vector3(maxed, 5, maxed) )
