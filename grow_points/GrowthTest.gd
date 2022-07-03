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

const GROW_BLOCKIFIER = preload("res://grow_points/GrowBlockifier.gd")
const SECONDARY_NODE = preload("res://grow_points/SecondaryNode.tscn")
onready var dd = get_node("/root/DebugDraw")

const X_WIDTH = 20
const Z_LENGTH = 30

export(Curve) var max_square_size

var blockifier = GROW_BLOCKIFIER.new()
var pass_count = 0

var points_to_mesh = {}

func _ready():
    var new_node
    
    blockifier.max_square_size = max_square_size
    blockifier.x_width = X_WIDTH
    blockifier.z_length = Z_LENGTH

    # Spawn in the blocks
    blockifier.spawn_pass()

    for block in blockifier._blocks:
        for grow_aabb in block.all_aabbs:
            new_node = MeshInstance.new()
            self.add_child(new_node)
            new_node.mesh = PlaneMesh.new()
            new_node.set_surface_material(
                0, MATERIALS[ randi() % len(MATERIALS)]
            )
            points_to_mesh[grow_aabb] = new_node
            
            new_node = SECONDARY_NODE.instance()
            self.add_child(new_node)
            new_node.translation = grow_aabb.origin + Vector3(0, 1, 0)
            

    $Timer.start()

func update_mesh(grow_aabb):
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