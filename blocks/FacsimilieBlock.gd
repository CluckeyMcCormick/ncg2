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
    # Show the mesh
    $BlockMesh.visible = true
    
    # Call the appropriate entry function on our parent city group
    get_tree().call_group(
        parent_city_group,          # Group Name
        "_on_any_block_enter_screen",  # Function-to-call
        self                        # 1st function argument: FacsimilieBlock
    )

func _on_VisibilityNotifier_screen_exited():
    # Hide the mesh
    $BlockMesh.visible = false
    # Call the appropriate exit function on our parent city group
    get_tree().call_group(
        parent_city_group,          # Group Name
        "_on_any_block_exit_screen",  # Function-to-call
        self                        # 1st function argument: FacsimilieBlock
    )

func copy_func_group(func_group):
    $BlockMesh.mesh = func_group.get_child(0).mesh

