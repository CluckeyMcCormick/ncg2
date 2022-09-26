extends Spatial

const GlobalRef = preload("res://util/GlobalRef.gd")
const GROW_BLOCKIFIER = preload("res://grow_points/GrowBlockifier.gd")
const SECONDARY_NODE = preload("res://grow_points/SecondaryNode.tscn")
const BUILDING_SCENE = preload("res://factory/TemplateBuilding.tscn")

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

var _total_buildings = 0
var _current_buildings = 0

# Emitted when the city is completed and ready for display!
signal city_complete()

func start_make_chain():
    
    print("Stage 1: Block Factory")
    
    $BlockFactory.block_x_width = block_x_width
    $BlockFactory.block_z_length = block_z_length
    $BlockFactory.buildings_per_block = buildings_per_block
    $BlockFactory.blocks = blocks
    
    $BlockFactory.max_square_size = max_square_size
    $BlockFactory.min_height = min_height
    $BlockFactory.max_height = max_height
    
    $BlockFactory.start_make_blocks_thread()

func clean_buildings():
    # For each child under the building master
    for child in $BuildingMaster.get_children():
        # Remove it
        $BuildingMaster.remove_child(child)
        # Free it
        child.queue_free()

func _on_BlockFactory_blocks_completed(grow_aabbs):
    var grow_aabb
    
    var fp_x = 0
    var fp_z = 0
    var height = 0
    
    var blueprint = {}
    
    var origin = Vector3.ZERO
    var scale = Vector3( BUILDING_SCALAR, BUILDING_SCALAR, BUILDING_SCALAR )
    
    print("Stage 2: Building Factory, Blueprints")
    
    while not grow_aabbs.empty():
        grow_aabb = grow_aabbs.pop_front()
        
        fp_x = int(grow_aabb.b.x - grow_aabb.a.x) * WINDOW_SCALING - 1
        fp_z = int(grow_aabb.b.z - grow_aabb.a.z) * WINDOW_SCALING - 1
        height = int(grow_aabb.height) * WINDOW_SCALING
        
        origin.x = (grow_aabb.b.x * WINDOW_SCALING + grow_aabb.a.x * WINDOW_SCALING) / 2
        origin.x *= GlobalRef.WINDOW_UV_SIZE * BUILDING_SCALAR
        origin.y = 0
        origin.z = (grow_aabb.b.z * WINDOW_SCALING + grow_aabb.a.z * WINDOW_SCALING) / 2
        origin.z *= GlobalRef.WINDOW_UV_SIZE * BUILDING_SCALAR
        
        # Start a thread to make a blueprint
        $BuildingFactory.start_make_blueprint_thread(
            fp_x, fp_z, height, origin, scale
        )
        
        # Increment our total buildings
        _total_buildings += 1

func _on_BuildingFactory_blueprint_completed(blueprint):
    var building : Spatial
    
    building = $BuildingFactory.construct_building($BuildingMaster, blueprint)
    
    # TODO: Visibility AABB?
    
    _current_buildings += 1

    if _current_buildings == _total_buildings:
        emit_signal("city_complete")
