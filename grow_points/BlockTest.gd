extends Spatial

const MATERIALS = [
    preload("res://voronoi/VoroniColorA.material"),
    preload("res://voronoi/VoroniColorB.material"),
    preload("res://voronoi/VoroniColorC.material"),
    preload("res://voronoi/VoroniColorD.material"),
    preload("res://voronoi/VoroniColorE.material"),
    preload("res://voronoi/VoroniColorF.material"),
    preload("res://voronoi/VoroniColorG.material"),
    preload("res://voronoi/VoroniColorH.material"),
    preload("res://voronoi/VoroniColorI.material"),
    preload("res://voronoi/VoroniColorJ.material"),
]

const GlobalRef = preload("res://util/GlobalRef.gd")
const GROW_BLOCKIFIER = preload("res://grow_points/GrowBlockifier.gd")
const SECONDARY_NODE = preload("res://grow_points/SecondaryNode.tscn")
const AUTO_TOWER = preload("res://buildings/AutoTower.tscn")

onready var dd = get_node("/root/DebugDraw")

const X_WIDTH = 30
const Z_LENGTH = 120

export(Curve) var max_square_size

var blockifier = null

func _ready():
    var new_node
    
    $GUI/OptionsBox/XBox.value = X_WIDTH
    $GUI/OptionsBox/ZBox.value = Z_LENGTH
    $GUI/OptionsBox/BuildingBox.value = 20
    
    blockifier = GROW_BLOCKIFIER.new( max_square_size, X_WIDTH, Z_LENGTH, 20 )

    # Spawn in the blocks
    generate_blocks()
    spawn_buildings()

func generate_blocks():
    blockifier.spawn_pass()
    while blockifier.has_viable_blocks():
        # Grow the blocks
        blockifier.grow_pass()
        
        # Clean the blocks
        blockifier.clean_pass()

func spawn_buildings():
    var grow_aabb
    var autotower
    while not blockifier._complete_aabbs.empty():
        grow_aabb = blockifier._complete_aabbs.pop_front()
        
        autotower = AUTO_TOWER.instance()
        autotower.len_x = int(grow_aabb.b.x - grow_aabb.a.x) * 2 - 1
        autotower.len_z = int(grow_aabb.b.z - grow_aabb.a.z) * 2 - 1
        
        $BuildingMaster.add_child(autotower)
        autotower.translation.x = (grow_aabb.b.x * 2 + grow_aabb.a.x * 2) / 2
        autotower.translation.x *= GlobalRef.WINDOW_UV_SIZE
        autotower.translation.z = (grow_aabb.b.z * 2 + grow_aabb.a.z * 2) / 2
        autotower.translation.z *= GlobalRef.WINDOW_UV_SIZE


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
        print("Remove")

    blockifier = GROW_BLOCKIFIER.new(
        max_square_size,
        int($GUI/OptionsBox/XBox.value),
        int($GUI/OptionsBox/ZBox.value),
        int($GUI/OptionsBox/BuildingBox.value)
    )
    generate_blocks()
    spawn_buildings()
