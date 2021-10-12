extends Spatial

# What's the path to a block cache's worldspawn mesh instance? This is what we
# use to quickly and easily extract the mesh from a Qodot block. 
const WORLDSPAWN_PATH = "/entity_0_worldspawn/entity_0_mesh_instance"

signal block_on_screen(facsimilie_block)

# Although all the blocks are the same size, there's a lot of translation
# between different formats and the exact size/scale may mutate. Ergo, we need
# to adjust the visibility block appropriately.
func update_block_visibility(godot_block_length, godot_max_height):
    # First, adjust the size of the visibility block. It needs to be double the
    # size because we need to know just BEFORE the block comes on screen
    $VisibilityNotifier.aabb.size.x = godot_block_length * 2
    $VisibilityNotifier.aabb.size.y = godot_max_height + 1
    $VisibilityNotifier.aabb.size.z = godot_block_length * 2
    
    # Second, adjust the position so it's centered (except for y)
    $VisibilityNotifier.aabb.position.x = -godot_block_length
    $VisibilityNotifier.aabb.position.y = -1
    $VisibilityNotifier.aabb.position.z = -godot_block_length

# When the PopupBlock enters the screen, send a signal to anyone who's listening
func _on_VisibilityNotifier_screen_entered():
    emit_signal("block_on_screen", self)

func copy_qodot_block(qodot_node):
    var mesh_path = str( qodot_node.get_path() ) + WORLDSPAWN_PATH
    var target_mesh = get_node(mesh_path)
    $BlockMesh.mesh = target_mesh.mesh
