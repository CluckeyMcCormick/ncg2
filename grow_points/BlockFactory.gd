extends Node

const GlobalRef = preload("res://util/GlobalRef.gd")

const GROW_BLOCKIFIER = preload("res://grow_points/GrowBlockifier.gd")

# Signal emitted when the blocks have been generated. The value emitted is a
# list of GrowAABB objects (see BuildingGrowPoint.gd). Each GrowAABB is
# effectively a footprint where a building can go.
signal blocks_completed(grow_aabbs)

# How wide is a block (length on X), in Window Units?
export(int) var block_x_width = 30
# How long is a block (length on Z), in Window Units?
export(int) var block_z_length = 120
# How many buildings per block?
export(int) var buildings_per_block = 20
# How many blocks?
export(int, 1, 100) var blocks = 50

#
export(Curve) var max_square_size
export(Curve) var min_height
export(Curve) var max_height

# Thread for growing the blockifier's blocks
var thread = null

# --------------------------------------------------------
#
# Build Functions
#
# --------------------------------------------------------

func start_make_blocks_thread():
    var err
    
    # If we have a thread, we need to handle that.
    if thread != null:
        print("Attempted to start make-blocks thread when previous thread hasn't yet been cleaned!")
        print("Cowardly refusing to start a duplicate make-blocks thread.")
        return false
    
    # Create a new thread
    thread = Thread.new()
    
    # Launch the blueprint-crafting thread
    err = thread.start(self, "make_blocks", true)
    
    # Return true if we successfully started a thread.
    return err == OK

func make_blocks(emit_signal=false):
    var grow_aabbs = []
    
    # Create a new blockifier
    var blockifier = GROW_BLOCKIFIER.new(
        max_square_size, min_height, max_height,
        block_x_width, block_z_length, buildings_per_block
    )
    
    # Spawn all the blocks
    blockifier.spawn_step()
    
    # While we still have blocks that are viable...
    while blockifier.has_viable_blocks():
        # Grow
        blockifier.grow_pass()
        # Clean
        blockifier.clean_pass()
    
    # Get a (shallow) copy of all the GrowAABB objects that were generated. Each
    # one of these is, in effect, a footprint for a building.
    grow_aabbs = blockifier._complete_aabbs.duplicate()
    
    # Disconnect the blockifier, which should dereference and clean it up.
    blockifier = null
    
    # If we're supposed to emit a signal, emit a signal
    if emit_signal:
        emit_signal("blocks_completed", grow_aabbs)
    
    return grow_aabbs
    
func thread_cleanup():
    # If we don't have a thread, can't very well do anything can we? Return
    # false.
    if thread == null:
        return false
    
    # If the thread is still ongoing, we're not interested.
    if thread.is_alive():
        print("Block Factory Thread is still alive!")
        print("Cowardly refusing to clean up an ongoing thread!")
        return false
    
    # Wait until the thread is finished.
    thread.wait_to_finish()
    
    # Clear the current thread
    thread = null
    
    # Clean-up complete! Return true.
    return true
