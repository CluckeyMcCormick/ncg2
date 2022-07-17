extends Spatial

const GlobalRef = preload("res://util/GlobalRef.gd")
const GROW_BLOCKIFIER = preload("res://grow_points/GrowBlockifier.gd")
const SECONDARY_NODE = preload("res://grow_points/SecondaryNode.tscn")
const BUILDING_SCENE = preload("res://buildings/FootprintBuilding.tscn")

const BUILDING_SCALAR = 10

onready var dd = get_node("/root/DebugDraw")

export(int) var block_x_width = 30
export(int) var block_z_length = 120
export(int) var buildings_per_block = 20

export(Curve) var max_square_size
export(Curve) var min_height
export(Curve) var max_height

# The blockifier - for creating blocks and growing out building footprints
var blockifier = null

# Thread for growing the blockifier's blocks
var thread = null

var _total_buildings = 0
var _current_buildings = 0

# Emitted when the city is completed and ready for display!
signal city_complete()

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
    
    # Launch the blueprint-crafting thread
    thread = Thread.new()
    thread.start(self, "_make_thread")

func _physics_process(delta):
    # If we have a grow thread, and the thread is done...
    if thread != null and not thread.is_alive():
        # Wait for the thread to finish
        thread.wait_to_finish()
        # Clear it out
        thread = null
        # Spawn in the footprints
        spawn_buildings()

func _make_thread():
    # Spawn all the blocks
    blockifier.spawn_step()
    
    # While we still have blocks that are viable...
    while blockifier.has_viable_blocks():
        # Grow
        blockifier.grow_pass()
        # Clean
        blockifier.clean_pass()

func spawn_buildings():
    var grow_aabb
    var building
    
    print("Spawning buildings!")
    
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
        
        _total_buildings += 1

func _on_building_blueprint_completed(building):
    # Disconnect the signal
    building.disconnect(
        "blueprint_completed", self, "_on_building_blueprint_completed"
    )
    # Construct this building
    building.make_building()
    
    _current_buildings += 1
    
    if _current_buildings == _total_buildings:
        emit_signal("city_complete")
