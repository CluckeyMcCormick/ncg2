extends Spatial

# The co-routine return value. We use this to build up all the blocks
# progressively
var co_ro

# Capture the shifted position of the orthographic camera once we enter the
# scene. That way we can shift it around but mantain it's position
onready var ortho_shift = $OrthoCamera.translation

func _ready():
    yield(get_tree().create_timer(1.0), "timeout")

func _on_StateMachinePlayer_transited(from, to):
    print("Transition: ", from, " |to| ", to)
    
    # First, handle any cleanup.
    match from:
        "Entry":
            yield(get_tree().create_timer(1.0), "timeout")
        
        "CacheBuild":
            # Connect the BlockBuildTimer and BlockCache signals for the
            # CacheBuild state
            $BlockBuildTimer.disconnect("timeout", self, "_CacheBuild_on_BlockBuildTimer_timeout")
            $BlockBuildTimer.disconnect("timeout", self, "_CacheBuild_on_BlockCache_block_built")
        
            # Flip over the BlockCache
            $BlockCache.rotation_degrees.x = -180
            # Move the BlockCache down by one
            $BlockCache.translation.y = -1
            # Reset the OrthoCamera
            $OrthoCamera.global_transform.origin = ortho_shift
        _:
            pass
    
    # Next, handle entry into the state
    match to:
        "CacheBuild":
            # Connect the BlockBuildTimer and BlockCache signals for the
            # CacheBuild state
            $BlockBuildTimer.connect("timeout", self, "_CacheBuild_on_BlockBuildTimer_timeout")
            $BlockCache.connect("block_built", self, "_CacheBuild_on_BlockCache_block_built")
            
            # Set the Orthogonal Camera to be the "current" camera.
            $OrthoCamera.current = true
            $PerspCamera.current = false
            
            # Start building all of the blocks, capture the co-routine yield
            co_ro = $BlockCache.build_all_blocks()
            
            # Start the Build Timer. We need the timer because building Qodot
            # maps too quickly breaks everything.
            $BlockBuildTimer.start()
            
        "PerspectiveCity":
            pass
        "OrthogonalCity":
            pass
        _:
            pass
    pass # Replace with function body.

# Whenever we timeout, build resume the BlockCache build process.
func _CacheBuild_on_BlockBuildTimer_timeout():
    # If the co-routine is active...
    if co_ro is GDScriptFunctionState && co_ro.is_valid():
        # Call the co-routine.
        co_ro = co_ro.resume();
        
        # If the co-routine is still active...
        if co_ro is GDScriptFunctionState:
            # Schedule the BlockBuildTimer. Again.
            $BlockBuildTimer.start()
        # Otherwise...
        else:
            # Guess we're done! TRIGGER the state machine switch
            $StateMachinePlayer.set_trigger("build_complete")

# Whenever the BlockCache builds a block, update the Camera position.
func _CacheBuild_on_BlockCache_block_built(godot_path, real_path, local_pos, global_pos):
    $OrthoCamera.global_transform.origin = global_pos + ortho_shift