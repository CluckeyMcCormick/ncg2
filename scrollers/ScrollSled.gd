extends Spatial

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# How "deep" (length on z) is the slide as a whole?
export(int) var slide_depth = 2 setget set_slide_depth

# How fast does the sled scroll, in units/sec?
export(int) var move_speed = 2

# Is the sled's building visible?
var building_vis = false

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
    
    # Move the omni-light, as necessary
    if self.has_node("OmniLight"):
        # Move the Omni-Light, as appropriate.
        $OmniLight.translation.z = new_depth / 2

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
    # We'll assume the 
    # Move the Omni-Light, as appropriate.
    $OmniLight.translation.z = slide_depth / 2
    
    var length = ($FSB.len_x * GlobalRef.WINDOW_UV_SIZE) * $FSB.scale.x
    var depth = ($FSB.len_z * GlobalRef.WINDOW_UV_SIZE) * $FSB.scale.z
    var c_squared = sqrt(pow(length, 2) + pow(depth, 2))
    var maxed = max( max(length, depth), c_squared )
    
    $FSB.translation.x = (maxed / 2) + 1
