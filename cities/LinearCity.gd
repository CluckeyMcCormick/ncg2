extends Spatial

# Preload the Facsimilie Block 
const FACSIMILIE_BLOCK = preload("res://blocks/FacsimilieBlock.tscn")

# What's the group name we'll provide to the facsimilie blocks - so we know when
# any block enters the screen?
const GROUP_NAME = "LinearCity"

# The block cache we'll use to set the buildings/meshes of our various
# Facsimilie Blocks. This needs to be set via code.
var block_cache

# Called when the node enters the scene tree for the first time.
func _ready():
    
    # Assert that we actually got a block cache. This will only catch it for
    # debug builds but that SHOULD be enough.
    assert(not block_cache == null)
    
    # Create a "seed block" from which all the other blocks will flow
    var seed_block = FACSIMILIE_BLOCK.instance()
    
    # Give it our first group! We'll just assume that's what we'll need. Yeah,
    # that probably won't backfire.
    seed_block.parent_city_group = GROUP_NAME
    
    # STICK IT!
    self.add_child(seed_block)

func _on_any_block_enter_screen(facsimilie_block):
    # First, give the requesting block a Qodot mesh
    var chosen_map = block_cache.get_random_map()
    facsimilie_block.copy_qodot_block(block_cache.map_to_node[chosen_map])
    
    # Next, if we don't have a left block, make one of those.
    if facsimilie_block.left_neighbor == null:
        # Create the left block
        var left_block = FACSIMILIE_BLOCK.instance()
        
        # Neighborize the two blocks
        facsimilie_block.left_neighbor = left_block
        left_block.right_neighbor = facsimilie_block
        
        # Adjust the translation of the left block
        left_block.translation = Vector3.LEFT * block_cache.BLOCK_SIDE_LENGTH
        left_block.translation += facsimilie_block.translation
        
        # Give it the group
        left_block.parent_city_group = GROUP_NAME
        
        # STICK IT!
        self.add_child(left_block)
    
    #If we don't have a right block, make one of those.
    if facsimilie_block.right_neighbor == null:
        # Create the left block
        var right_block = FACSIMILIE_BLOCK.instance()
        
        # Neighborize the two blocks
        facsimilie_block.right_neighbor = right_block
        right_block.left_neighbor = facsimilie_block
        
        # Adjust the translation of the right block
        right_block.translation = Vector3.RIGHT * block_cache.BLOCK_SIDE_LENGTH
        right_block.translation += facsimilie_block.translation
        
        # Give it the group
        right_block.parent_city_group = GROUP_NAME
        
        # STICK IT!
        self.add_child(right_block)

func _on_any_block_exit_screen(facsimilie_block):
    # First, get the left & right neighbor blocks in some shorthand variables
    var left = facsimilie_block.left_neighbor
    var right = facsimilie_block.right_neighbor
    
    # Secondly, wrap the neighbors in weak references 
    var weak_left = weakref(left)
    var weak_right = weakref(right)
    
    # If we have a left neighbor, and the left neighbor is not visible, then
    # free the neighbor.
    if weak_left.get_ref() and not left.is_effectively_visibile():
        left.queue_free()
        facsimilie_block.left_neighbor = null

    # If we have a right neighbor, and the right neighbor is not visible, then
    # free the neighbor.
    if weak_right.get_ref() and not right.is_effectively_visibile():
        right.queue_free()
        facsimilie_block.right_neighbor = null
    
    # If we don't have a left neighbor or a right neighbor, then we're an
    # orphan. Let's free ourselves!
    if (not weak_left.get_ref()) and (not weak_right.get_ref()):
        facsimilie_block.queue_free()
