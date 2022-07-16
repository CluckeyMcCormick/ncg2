extends Spatial

const GlobalRef = preload("res://util/GlobalRef.gd")
const GROW_BLOCKIFIER = preload("res://grow_points/GrowBlockifier.gd")
const SECONDARY_NODE = preload("res://grow_points/SecondaryNode.tscn")
const BUILDING_SCENE = preload("res://buildings/FootprintBuilding.tscn")

const BUILDING_SCALAR = 10

const MSEC_TARGET = 5

onready var dd = get_node("/root/DebugDraw")

export(int) var block_x_width = 30
export(int) var block_z_length = 120
export(int) var buildings_per_block = 20

export(Curve) var max_square_size
export(Curve) var min_height
export(Curve) var max_height

# The blockifier - for creating blocks and growing out building footprints
var blockifier = null

# Block Origins to corresponding VisibilityNotifier nodes. Used to ensure we
# only set up one VisibilityNotifier for each block
var origin_to_notifier = {}

# Thread for growing the blockifier's blocks
var thread = null

var to_build = []

# TODO: Scale the buildings individually, not using the BuildingMaster node.
# TODO: Shift buildings that get hidden by the city length

func _ready():
    var new_node
    
    # Assert the building scalar and rotation
    $BuildingMaster.scale = Vector3(
        BUILDING_SCALAR, BUILDING_SCALAR, -BUILDING_SCALAR
    )
    $BuildingMaster.rotation_degrees = Vector3.ZERO
    
    # Create a new blockifier
    blockifier = GROW_BLOCKIFIER.new(
        max_square_size, min_height, max_height,
        block_x_width, block_z_length, buildings_per_block
    )

    # Spawn some blocks
    spawn_blocks()
    # Grow those blocks until we have something to spawn
    grow_blocks()
    # Spawn some buildings
    spawn_buildings()

func _physics_process(delta):
    # How many ticks did we start with?
    var start_ticks
    # How many ticks do we have now?
    var current_ticks
    # What's our current building?
    var building
    
    # Catch the current tick count
    start_ticks = OS.get_ticks_msec()
    
    # If we have a grow thread, and the thread is done...
    if thread != null and not thread.is_alive():
        # Wait for the thread to finish
        thread.wait_to_finish()
        # Spawn in the footprints
        spawn_buildings()
        thread = null
    
    # Get the current tick count
    current_ticks = OS.get_ticks_msec()
    
    # While we still have buildings to build, and we're under our millisecond
    # target...
    while not to_build.empty() and current_ticks - start_ticks < MSEC_TARGET:
        # Get the next building
        building = to_build.pop_front()
        # Make that building
        building.make_building()
        # What time are we at now?
        current_ticks = OS.get_ticks_msec()
    
func spawn_blocks():
    var node
    
    # Spawn some blocks/buildings
    blockifier.spawn_pass()
    
    # For each block...
    for block in blockifier._blocks:
        # If this block's origin already has a visual notifier, skip it
        if block.block_origin in origin_to_notifier:
            continue
        
        # Create a visibility notifier for this node
        node = VisibilityNotifier.new()
        
        # Ensure the notifier sits over the block's space
        node.aabb.position = block.block_origin * GlobalRef.WINDOW_UV_SIZE
        node.aabb.position = node.aabb.position * BUILDING_SCALAR
        # Ensure the notifier is an appropriate size for this block
        node.aabb.size.y = 100 # Just make it really tall
        node.aabb.size.x = block.x_width * GlobalRef.WINDOW_UV_SIZE
        node.aabb.size.x = node.aabb.size.x * BUILDING_SCALAR
        node.aabb.size.z = block.z_length * GlobalRef.WINDOW_UV_SIZE
        node.aabb.size.z = node.aabb.size.z * -BUILDING_SCALAR
        
        # Stick it in the scene, register the methods
        $VisibilityMaster.add_child(node)
        node.connect("screen_entered", self, "_on_block_screen_entered", [node])
        
        # Stick it in our tracking dictionaries
        origin_to_notifier[block.block_origin] = node

func grow_blocks():
    # Grow until we have a new set of aabbs (this means a block was completed)
    while blockifier._complete_aabbs.empty():
        blockifier.grow_pass()
        blockifier.clean_pass()

func spawn_buildings():
    var grow_aabb
    var building
    while not blockifier._complete_aabbs.empty():
        grow_aabb = blockifier._complete_aabbs.pop_front()
        
        building = BUILDING_SCENE.instance()
        building.footprint_len_x = int(grow_aabb.b.x - grow_aabb.a.x) * 2 - 1
        building.footprint_len_z = int(grow_aabb.b.z - grow_aabb.a.z) * 2 - 1
        building.tower_len_y = int(grow_aabb.height)
        
        building.connect(
            "blueprint_completed", self, "_on_building_blueprint_completed"
        )
        
        $BuildingMaster.add_child(building)
        building.translation.x = (grow_aabb.b.x * 2 + grow_aabb.a.x * 2) / 2
        building.translation.x *= GlobalRef.WINDOW_UV_SIZE
        building.translation.z = (grow_aabb.b.z * 2 + grow_aabb.a.z * 2) / 2
        building.translation.z *= GlobalRef.WINDOW_UV_SIZE

func _on_block_screen_entered(block_vis):
    # First, we need to remove the notifier that emitted this signal from our
    # origin-check-dictionary
    for key in origin_to_notifier.keys():
        if origin_to_notifier[key] != block_vis:
            continue
        origin_to_notifier.erase(key)
        break
    
    # Break the signal
    block_vis.disconnect("screen_entered", self, "_on_block_screen_entered")
    
    # Remove and delete the visibility modifier
    $VisibilityMaster.remove_child(block_vis)
    block_vis.queue_free()
    
    # If we don't have a thread active...
    if thread == null:
        # Spawn in some new blocks
        spawn_blocks()
        
        # Create and start a new thread
        thread = Thread.new()
        thread.start(self, "grow_blocks")

func _on_building_blueprint_completed(building):
    building.disconnect(
        "blueprint_completed", self, "_on_building_blueprint_completed"
    )
    to_build.append(building)
