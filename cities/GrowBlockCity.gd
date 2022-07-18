extends Spatial

const GlobalRef = preload("res://util/GlobalRef.gd")
const GROW_BLOCKIFIER = preload("res://grow_points/GrowBlockifier.gd")
const SECONDARY_NODE = preload("res://grow_points/SecondaryNode.tscn")
const BUILDING_SCENE = preload("res://buildings/FootprintBuilding.tscn")

# If we kepp the buildings at their actual sizes, you'll find they're very
# small. That's because they're purposefully scaled around the sizes of the
# building windows, as given by GlobalRef.WINDOW_UV_SIZE. Anyway, by what scalar
# do we want to scale the buildings up by, making them more visible?
const BUILDING_SCALAR = 10

# Now, the footprints that we generate from the blockifier are measured in
# window units. We could flat translate them, OR we could scale up the number of
# windows - which we do to achieve a more full city.
const WINDOW_SCALING = 2

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

func _ready():
    var new_node
    
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
        building.footprint_len_x = int(grow_aabb.b.x - grow_aabb.a.x) * WINDOW_SCALING - 1
        building.footprint_len_z = int(grow_aabb.b.z - grow_aabb.a.z) * WINDOW_SCALING - 1
        building.tower_len_y = int(grow_aabb.height) * WINDOW_SCALING
        
        building.connect(
            "blueprint_completed", self, "_on_building_blueprint_completed"
        )
        building.connect("screen_exited", self, "_on_building_screen_exited")
        
        $BuildingMaster.add_child(building)
        building.translation.x = (grow_aabb.b.x * WINDOW_SCALING + grow_aabb.a.x * WINDOW_SCALING) / 2
        building.translation.x *= GlobalRef.WINDOW_UV_SIZE * BUILDING_SCALAR
        building.translation.z = (grow_aabb.b.z * WINDOW_SCALING + grow_aabb.a.z * WINDOW_SCALING) / 2
        building.translation.z *= GlobalRef.WINDOW_UV_SIZE * BUILDING_SCALAR
        building.scale = Vector3(
            BUILDING_SCALAR, BUILDING_SCALAR, BUILDING_SCALAR
        )
        
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

func _on_building_screen_exited(building):
    var trans = Vector3.ZERO
    
    trans.x += blockifier.target_blocks * blockifier.x_width * WINDOW_SCALING
    trans.x *= GlobalRef.WINDOW_UV_SIZE * BUILDING_SCALAR
    
    building.translation += trans
