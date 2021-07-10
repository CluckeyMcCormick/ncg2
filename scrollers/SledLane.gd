tool
extends Spatial

# Load the scroll-sled script
const ScrollSled = preload("res://util/GlobalRef.gd")
# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# Load the scroll-sled scene
const scroll_sled_scene = preload("res://scrollers/ScrollSled.tscn")

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# What's the minimum length for a building in this lane on x?
export(int) var width_min = 5 setget set_width_min
# What's the maximum length for a building in this lane on x?
export(int) var width_max = 9 setget set_width_max

# What's the minimum length for a building in this lane on z?
export(int) var depth_min = 4 setget set_depth_min
# What's the maximum length for a building in this lane on z?
export(int) var depth_max = 8 setget set_depth_max

# What's the minimum length for a building's base, in this lane, on y?
export(int) var base_height_min = 2 setget set_base_height_min
# What's the maximum length for a building's base, in this lane, on y?
export(int) var base_height_max = 4 setget set_base_height_max

# What's the minimum length for a building in this lane on y?
export(int) var tower_height_min = 4 setget set_tower_height_min
# What's the maximum length for a building in this lane on y?
export(int) var tower_height_max = 8 setget set_tower_height_max

# What's the standard deviation for the rotation of any given building on a
# sled? This is a "deviation" in the terms of a Gaussian Distribution, meaning
# that 68% will be within plus-or-minus this value.
export(float) var rotation_deviation = 45

# What's the minimum "extra" space between buildings (measured in window cells)?
export(int) var min_extra_space = 0
# What's the maximum "extra" space between buildings (measured in window cells)?
export(int) var max_extra_space = 0

# Each sled has one light that we vary the range of using a gaussian
# distribution. What is the mean of that distribution?
export(float) var mean_light_range = 4.0
# Each sled has one light that we vary the size of using a gaussian
# distribution. What is the mean of that distribution?
export(float) var light_size_deviation = 0.0

# Everytime we make a new sled, we roll the color for the light from one of
# three pools. These boolean exports control the available colors to choose
# from.
export(bool) var use_light_color_one = true
export(bool) var use_light_color_two = false
export(bool) var use_light_color_three = false

# What's the last sled we made?
var last_sled = null

# How much extra space do we wait for until spawning a new building?
var last_spacer = 0

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
    
    # If we don't have a last sled, make a new sled
    if not is_instance_valid(last_sled):
        make_sled()
    
    # Otherwise, if the local translation of the sled, on X, exceeds or meets
    # the potential max x-length of the sled...
    if abs(last_sled.translation.x) >= (last_sled.max_poss_x_len + last_spacer):
        # Then make a new sled
        make_sled()

# --------------------------------------------------------
#
# Setters and Getters
#
# --------------------------------------------------------
func get_random_int(min_val, max_val):
    if(min_val == max_val):
        return min_val
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
        
func set_base_height_min(new_base_height):
    base_height_min = new_base_height
    if Engine.editor_hint:
        make_debug()
    
func set_base_height_max(new_base_height):
    base_height_max = new_base_height
    if Engine.editor_hint:
        make_debug()

func set_tower_height_min(new_tower_height):
    tower_height_min = new_tower_height
    if Engine.editor_hint:
        make_debug()
    
func set_tower_height_max(new_tower_height):
    tower_height_max = new_tower_height
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
    
    # Adjust the range on the sled's light.
    new_sled.set_light_range(RNGENNIE.randfn(mean_light_range, light_size_deviation))
    
    # Roll a new color
    var colors = []
    
    if use_light_color_one:
        colors.append(mcc.light_color_one)
    
    if use_light_color_two:
        colors.append(mcc.light_color_two)
 
    if use_light_color_three:
        colors.append(mcc.light_color_three)
    
    if len(colors) > 0:
        new_sled.set_light_color(colors[randi() % len(colors)])
    else:
        new_sled.set_light_color(Color("#000000"))
   
    # Set the material
    new_sled.set_building_material( mcc.primary_material )

    # Stick the sled in the tree
    self.add_child(new_sled)
    # Force the sled's FSB to build
    new_sled.make_building()
    
    # This is now the last sled 
    last_sled = new_sled
    
    # Now we need to roll the "extra space" to the next building (if we can even
    # do such a thing!)
    if max_extra_space > 0:
        last_spacer = get_random_int(min_extra_space, max_extra_space)
        last_spacer *= GlobalRef.WINDOW_UV_SIZE * 10
    else:
        last_spacer = 0

func make_debug():
    # If we don't have a mesh to mess with, back out.
    if not self.has_node("Squish") or not self.has_node("Stretch") or not self.has_node("Footprint"):
        return
    
    var min_width = (width_min * GlobalRef.WINDOW_UV_SIZE) * 10
    var max_width = (width_max * GlobalRef.WINDOW_UV_SIZE) * 10
    
    var min_depth = (depth_min * GlobalRef.WINDOW_UV_SIZE) * 10
    var max_depth = (depth_max * GlobalRef.WINDOW_UV_SIZE) * 10
    
    var min_height = ((base_height_min + tower_height_min) * GlobalRef.WINDOW_UV_SIZE) * 10
    var max_height = ((base_height_max + tower_height_max) * GlobalRef.WINDOW_UV_SIZE) * 10
    
    var c_squared = sqrt(pow(max_width, 2) + pow(max_depth, 2))
    
    $Squish.mesh = CubeMesh.new()
    $Squish.mesh.set_size( Vector3(max_width, min_height, max_depth) )
    $Squish.translation.y = min_height / 2

    $Stretch.mesh = CubeMesh.new()
    $Stretch.mesh.set_size( Vector3(min_width, max_height, min_depth) )
    $Stretch.translation.y = max_height / 2
    
    $Footprint.mesh = PlaneMesh.new()
    $Footprint.mesh.set_size( Vector2(c_squared, c_squared) )
