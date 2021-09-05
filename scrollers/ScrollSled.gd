extends Spatial

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

const FSB_SHIFT = GlobalRef.WINDOW_UV_SIZE * 2

# How "deep" (length on z) is the slide as a whole?
export(int) var slide_depth = 2 setget set_slide_depth

# How fast does the sled scroll, in units/sec?
export(int) var move_speed = 2

# Is the sled's building visible?
var building_vis = false

# What we consider to be the effective length of the sled, for reference. This
# isn't actually an exact calculation, especially if the building has been
# rotated; rather, it reflects the maximum possible extent of space that a
# building can take up. This is set when the sled is built; 1 is just a default.
var max_poss_x_len = 1

# Called when the node enters the scene tree for the first time.
func _ready():
    make_slide()

# Auto-scroll the sled
func _process(delta):
    self.translate(Vector3(-move_speed, 0, 0) * delta)

# --------------------------------------------------------
#
# Setters, Getters, Signals
#
# --------------------------------------------------------
func set_slide_depth(new_depth):
    # Set the depth
    slide_depth = new_depth

# A wrapper function to set the proportions of the building, since whatever
# spawns the sled might not be able to reach down directly.
func set_building_size(len_x, len_z, base_height, tower_height):
    $FSB.len_x = len_x
    $FSB.len_z = len_z
    $FSB.base_len_y = base_height
    $FSB.tower_len_y = tower_height

# A wrapper function to set the rotation of the building, since whatever spawns
# the sled might not be able to reach down directly.
func set_building_y_rotation(degrees):
    $FSB.rotation_degrees.y = degrees

# A wrapper function to set the building material, since whatever spawns the
# sled might not be able to reach down directly. Note that this doesn't change
# building material directly, the structure will need to rebuilt for that.
func set_building_material(material):
    $FSB.building_material = material

func _on_VisibilityNotifier_screen_exited():
    # We exited the screen! This only happens on an exit, meaning we've already
    # entered the screen before. That means our scroll is done, and it's time to
    # delete the sled.
    queue_free()

# --------------------------------------------------------
#
# Build Functions
#
# --------------------------------------------------------
func make_slide():
    # Calculate the max 
    var length = ($FSB.len_x * GlobalRef.WINDOW_UV_SIZE) * $FSB.scale.x
    var depth = ($FSB.len_z * GlobalRef.WINDOW_UV_SIZE) * $FSB.scale.z
    var c_squared = sqrt(pow(length, 2) + pow(depth, 2))
    var maxed = max( max(length, depth), c_squared )
    
    # Translate the building over by the appropriate shift AND half the
    # max-possible size of the sled.
    $FSB.translation.x = (FSB_SHIFT * $FSB.scale.x) + (maxed / 2)
    # Set that max-possible length on x
    max_poss_x_len = (FSB_SHIFT * $FSB.scale.x) + maxed

# A wrapper function to make the building, since whatever spawns the sled might
# not be able to reach down directly.
func make_building():
    $FSB.make_building()
