extends Spatial

# The co-routine return value. We use this to build up all the blocks
# progressively
var co_ro

# Capture the shifted position of the orthographic camera once we enter the
# scene. That way we can shift it around but mantain it's position
onready var ortho_shift = $OrthoCamera.translation

# Emitted when we finish building the cache.
signal cache_build_finished()

# Called when the node enters the scene tree for the first time.
func _ready():
    # Give Godot a second to get started. Building the blocks too fast breaks
    # everything for some reason.
    yield(get_tree().create_timer(1.0), "timeout")
    # Start building all of the blocks, capture the co-routine yield
    co_ro = $BlockCache.build_all_blocks()
    # Start the Build Timer. We need the timer because building Qodot maps too
    # quickly breaks everything.
    $BlockBuildTimer.start()

# Whenever we timeout, build resume the BlockCache build process.
func _on_BlockBuildTimer_timeout():
    # If the co-routine is active...
    if co_ro is GDScriptFunctionState && co_ro.is_valid():
        # Call the co-routine.
        co_ro = co_ro.resume();
        
        # If the co-routine is still active...
        if co_ro is GDScriptFunctionState:
            # Schedule the BlockBuildTimer. Again.
            $BlockBuildTimer.start()

# Whenever the BlockCache builds a block, update the Camera position.
func _on_BlockCache_block_built(godot_path, real_path, local_pos, global_pos):
    $OrthoCamera.global_transform.origin = global_pos + ortho_shift
