extends Spatial

# What's the path to a block cache's worldspawn mesh instance? This is what we
# use to quickly and easily extract the mesh from a Qodot block. 
const WORLDSPAWN_PATH = "/entity_0_worldspawn/entity_0_mesh_instance"

# Unfortunately, you can't have multiple instances of the same scene/node attach
# to the same function for the same signal. So, instead, we're going to use
# Godot's groups, which basically works out as a many-to-many signal.
var parent_city_group

# These will point to our left and right neighbor blocks, and will thusly be
# used for determining if we even HAVE neighbors. This is meant to be set via
# code by some sort of controlling entity.
var left_neighbor = null
var right_neighbor = null

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

func is_effectively_visibile():
    return $VisibilityNotifier.is_on_screen()

# When the FacsimilieBlock enters the screen, call the parent group to handle
# it.
func _on_VisibilityNotifier_screen_entered():
    get_tree().call_group(
        parent_city_group,          # Group Name
        "_on_any_block_on_screen",  # Function-to-call
        self                        # 1st function argument: FacsimilieBlock
    )
    # Show the mesh
    $BlockMesh.visible = true
    

func _on_VisibilityNotifier_screen_exited():
    # Hide the mesh
    $BlockMesh.visible = false
    
    # Wrap the neighbors in weak references 
    var weak_left = weakref(left_neighbor)
    var weak_right = weakref(right_neighbor)
    
    # If we have a left neighbor, and the left neighbor is not visible, then
    # free the neighbor.
    if weak_left.get_ref() and not left_neighbor.is_effectively_visibile():
        left_neighbor.queue_free()
        left_neighbor = null

    # If we have a right neighbor, and the right neighbor is not visible, then
    # free the neighbor.
    if weak_right.get_ref() and not right_neighbor.is_effectively_visibile():
        right_neighbor.queue_free()
        right_neighbor = null
    
    # If we don't have a left neighbor or a right neighbor, then we're an
    # orphan. Let's free ourselves!
    if (not weak_left.get_ref()) and (not weak_right.get_ref()):
        self.queue_free()

func copy_qodot_block(qodot_node):
    var mesh_path = str( qodot_node.get_path() ) + WORLDSPAWN_PATH
    var target_mesh = get_node(mesh_path)
    $BlockMesh.mesh = target_mesh.mesh
