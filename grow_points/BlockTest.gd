extends Spatial

const MATERIALS = [
    preload("res://voronoi/VoroniColorA.tres"),
    preload("res://voronoi/VoroniColorB.tres"),
    preload("res://voronoi/VoroniColorC.tres"),
    preload("res://voronoi/VoroniColorD.tres"),
    preload("res://voronoi/VoroniColorE.tres"),
    preload("res://voronoi/VoroniColorF.tres"),
    preload("res://voronoi/VoroniColorG.tres"),
    preload("res://voronoi/VoroniColorH.tres"),
    preload("res://voronoi/VoroniColorI.tres"),
    preload("res://voronoi/VoroniColorJ.tres"),
]

const GlobalRef = preload("res://util/GlobalRef.gd")
const GROW_BLOCKIFIER = preload("res://grow_points/GrowBlockifier.gd")
const SECONDARY_NODE = preload("res://grow_points/SecondaryNode.tscn")
const BUILDING_SCENE = preload("res://buildings/FootprintBuilding.tscn")

onready var dd = get_node("/root/DebugDraw")

const X_WIDTH = 30
const Z_LENGTH = 200
const TARGET_BLOCKS = 8

# These two scalars are also used in the Grow Block City - they have been
# included here to mirror what is going on in that scene
const BUILDING_SCALAR = 1
const WINDOW_SCALING = 2

export(Curve) var max_square_size
export(Curve) var min_height
export(Curve) var max_height

var blockifier = null

# FIXME: Block Test is currently broken

func _ready():
    var new_node
    
    $GUI/OptionsBox/XBox.value = X_WIDTH
    $GUI/OptionsBox/ZBox.value = Z_LENGTH
    $GUI/OptionsBox/BuildingBox.value = 40
    
    blockifier = GROW_BLOCKIFIER.new(
        max_square_size, min_height, max_height, X_WIDTH, Z_LENGTH, 40
    )
    blockifier.target_blocks = TARGET_BLOCKS

    # Spawn in the blocks
    generate_blocks()
    spawn_buildings()

func generate_blocks():
    blockifier.spawn_step()
    while blockifier.has_viable_blocks():
        # Grow the blocks
        blockifier.grow_pass()
        
        # Clean the blocks
        blockifier.clean_pass()

func spawn_buildings():
    var grow_aabb
    var building
    while not blockifier._complete_aabbs.empty():
        grow_aabb = blockifier._complete_aabbs.pop_front()
        
        building = BUILDING_SCENE.instance()
        building.footprint_len_x = int(grow_aabb.b.x - grow_aabb.a.x) * WINDOW_SCALING - 1
        building.footprint_len_z = int(grow_aabb.b.z - grow_aabb.a.z) * WINDOW_SCALING - 1
        building.tower_len_y = int(grow_aabb.height) * WINDOW_SCALING
        
        building.connect(
            "blueprint_completed", self, "_on_building_blueprint_completed"
        )
        
        $BuildingMaster.add_child(building)
        building.translation.x = (grow_aabb.b.x * WINDOW_SCALING + grow_aabb.a.x * WINDOW_SCALING) / 2
        building.translation.x *= GlobalRef.WINDOW_UV_SIZE * BUILDING_SCALAR
        building.translation.z = (grow_aabb.b.z * WINDOW_SCALING + grow_aabb.a.z * WINDOW_SCALING) / 2
        building.translation.z *= GlobalRef.WINDOW_UV_SIZE * BUILDING_SCALAR
        building.scale = Vector3(
            BUILDING_SCALAR, BUILDING_SCALAR, BUILDING_SCALAR
        )

func _on_building_blueprint_completed(building):
    # Disconnect the signal
    building.disconnect(
        "blueprint_completed", self, "_on_building_blueprint_completed"
    )
    # Construct this building
    building.make_building()
    

func _on_CameraOptions_item_selected(index):
    if index == 0:
        $OrthoDownCamera.current = true
    elif index == 1:
        $FOV30Camera.current = true
    else:
        $FOV15Camera.current = true

func _on_RegenerateButton_pressed():
    for building in $BuildingMaster.get_children():
        $BuildingMaster.remove_child(building)
        building.queue_free()

    blockifier = GROW_BLOCKIFIER.new(
        max_square_size, min_height, max_height,
        int($GUI/OptionsBox/XBox.value),
        int($GUI/OptionsBox/ZBox.value),
        int($GUI/OptionsBox/BuildingBox.value)
    )
    blockifier.target_blocks = TARGET_BLOCKS
    generate_blocks()
    spawn_buildings()
