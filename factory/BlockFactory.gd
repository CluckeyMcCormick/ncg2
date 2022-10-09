extends Node

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

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

# These are "Z Curves" - curves that the Blockifier samples (indexing with the
# Grow AABB's Z value) to determine certain values.
# This curve determines the maximum possible size for a side of a GrowAABB.
export(Curve) var max_square_size
# This curve determines the minimum height for buildings, in window units.
export(Curve) var min_height
# This curve determines the maximum height for buildings, in window units.
export(Curve) var max_height

# Thread for growing the blockifier's blocks
var active_thread = null

# --------------------------------------------------------
#
# Godot Functions
#
# --------------------------------------------------------

func _ready():
    # Disable physics processing for this node. We only want to use that when a
    # thread is running.
    set_physics_process(false)

# The physics process function, called at a regular interval - we use this to
# check and see if the thread is done. We need to do that for two reasons:
# firstly, we need to know when the thread is done so we can clean it up.
# Secondly, Godot doesn't have "queued signals" like, say, Qt. Emitting a
# signal immediately calls the connected functions - meaning if we emit in a
# thread we call in that same thread. And that's bad! So we need to emit in this
# physics process function call.
func _physics_process(_delta):
    # We'll use this to capture output
    var grow_aabbs
    
    # If we don't have a thread, then we shouldn't be doing physics processing.
    # Disable it and back out.
    if active_thread == null:
        set_physics_process(false)
        return
    
    # If the thread is still alive, we can't do anything just yet. Back out.
    if active_thread.is_alive():
        return
    
    # Otherwise, we're good for cleanup! First, wait for the thread to finish.
    # This will return the list of Grow AABBs.
    grow_aabbs = active_thread.wait_to_finish()
    
    # Clear the current thread
    active_thread = null
    
    # Turn off our physics processing
    set_physics_process(false)
    
    # Tell the world our blocks are finished!
    emit_signal("blocks_completed", grow_aabbs)

# --------------------------------------------------------
#
# Build Functions
#
# --------------------------------------------------------

func start_make_blocks_thread():
    # Any errors?
    var err
    
    # If we have a thread, we need to handle that.
    if active_thread != null:
        print("Attempted to start make-blocks thread when previous thread hasn't yet been cleaned!")
        print("Cowardly refusing to start a duplicate make-blocks thread.")
        return false
    
    # Create a new blockifier
    var blockifier = GROW_BLOCKIFIER.new(
        max_square_size, min_height, max_height,
        block_x_width, block_z_length, buildings_per_block
    )
    
    # Create a new thread
    active_thread = Thread.new()
    
    # Launch the blueprint-crafting thread
    err = active_thread.start(self, "make_blocks")
    
    # No issues? Great! Start physics processing!
    if err == OK:
        set_physics_process(true)
    
    # Otherwise, we failed. Nullify the thread.
    else:
        active_thread = null
    
    # Return true if we successfully started a thread.
    return err == OK

func make_blocks():
    var grow_aabbs = []
    
    # Create a new blockifier
    var blockifier = GROW_BLOCKIFIER.new(
        max_square_size, min_height, max_height,
        block_x_width, block_z_length, buildings_per_block
    )
    
    # Carry down the correct number of blocks
    blockifier.target_blocks = blocks
    
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
    
    # Return the Grow AABBs
    return grow_aabbs
