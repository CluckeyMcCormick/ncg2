extends Spatial

const GROW_POINT = preload("res://grow_points/BuildingGrowPoint.gd")
const GROW_BLOCKIFIER = preload("res://grow_points/GrowBlockifier.gd")
const SECONDARY_NODE = preload("res://grow_points/SecondaryNode.tscn")
onready var dd = get_node("/root/DebugDraw")

const X_WIDTH = 20
const Z_LENGTH = 30

export(Curve) var max_square_size

var blockifier = GROW_BLOCKIFIER.new()
var pass_count = 0

func _ready():
    var new_node
    
    blockifier.max_square_size = max_square_size
    blockifier.x_width = X_WIDTH
    blockifier.z_length = Z_LENGTH

    # Spawn in the blocks
    blockifier.spawn_pass()

    for block in blockifier._blocks:
        for grow_aabb in block.all_aabbs:
            new_node = grow_aabb.mesh
            self.add_child(new_node)
            new_node.translation = grow_aabb.origin
            
            new_node = SECONDARY_NODE.instance()
            self.add_child(new_node)
            new_node.translation = grow_aabb.origin + Vector3(0, 1, 0)

    $Timer.start()

func _on_Timer_timeout():
    
    blockifier.grow_pass()
    blockifier.clean_pass()
    
    pass_count += 1
    
    $GUI/PassCount.text = str(pass_count)
    $GUI/BlockCount.text = str(len(blockifier._blocks))
    
    if blockifier.has_viable_blocks():
        $Timer.start()
    else:
        $Timer.stop()
