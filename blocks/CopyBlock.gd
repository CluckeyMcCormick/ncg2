extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func copy_qodot_block(qodot_node):
    
    var mesh_path = str( qodot_node.get_path() )
    mesh_path += "/entity_0_worldspawn/entity_0_mesh_instance"
    
    print(mesh_path)
    
    var target_mesh = get_node(mesh_path)
    $BlockMesh.mesh = target_mesh.mesh
