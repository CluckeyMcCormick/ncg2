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

const GROW_BLOCKIFIER = preload("res://grow_points/GrowBlockifier.gd")
const SECONDARY_NODE = preload("res://grow_points/SecondaryNode.tscn")
onready var dd = get_node("/root/DebugDraw")

const X_WIDTH = 30
const Z_LENGTH = 200
const TARGET_BLOCKS = 8

export(Curve) var max_square_size

var min_height = load("res://grow_points/BuildingMinHeightCurve.tres")
var max_height = load("res://grow_points/BuildingMaxHeightCurve.tres")

var blockifier = null
var pass_count = 0

var points_to_mesh = {}

func _ready():
    var current_mats = MATERIALS.duplicate()
    var new_node
    
    blockifier = GROW_BLOCKIFIER.new(
        max_square_size, min_height, max_height, X_WIDTH, Z_LENGTH, 40
    )
    blockifier.target_blocks = TARGET_BLOCKS
    
    # Spawn in the blocks
    blockifier.spawn_step()

    for block in blockifier._blocks:
        for grow_aabb in block.all_aabbs:
            new_node = MeshInstance.new()
            self.add_child(new_node)
            new_node.mesh = PlaneMesh.new()
            new_node.set_surface_material(
                0, current_mats.pop_front()
            )
            points_to_mesh[grow_aabb] = new_node
            
            new_node = SECONDARY_NODE.instance()
            self.add_child(new_node)
            new_node.translation = grow_aabb.origin + Vector3(0, 1, 0)
            
            if(current_mats.empty()):
                current_mats = MATERIALS.duplicate()

    $Timer.start()

func update_mesh(grow_aabb):
    if not grow_aabb in points_to_mesh:
        return
    
    var mesh = points_to_mesh[grow_aabb]
    
    mesh.translation = (grow_aabb.a + grow_aabb.b) / 2
    mesh.mesh.size = Vector2(
        grow_aabb.b.x - grow_aabb.a.x,
        grow_aabb.b.z - grow_aabb.a.z
    )
    

func _on_Timer_timeout():
    
    # Grow the blocks
    blockifier.grow_pass()
    
    # Update the meshes for all the GrowAABB
    for block in blockifier._blocks:
        for grow_aabb in block.all_aabbs:
            update_mesh(grow_aabb)
    
    # Clean the blocks
    blockifier.clean_pass()
    
    pass_count += 1
    
    $GUI/PassCount.text = str(pass_count)
    $GUI/BlockCount.text = str(len(blockifier._blocks))
    
    if blockifier.has_viable_blocks():
        $Timer.start()
    else:
        $Timer.stop()
