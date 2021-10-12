extends Spatial

const FACSIMILIE_BLOCK = preload("res://blocks/FacsimilieBlock.tscn")

# The block cache we'll use to set the buildings/meshes of our various
# Facsimilie Blocks. This needs to be set via code.
var block_cache

# Called when the node enters the scene tree for the first time.
func _ready():
    
    # Assert that we actually got a block cache. This will only catch it for
    # debug builds but that SHOULD be enough.
    assert(not block_cache == null)
    
    var seed_block = FACSIMILIE_BLOCK.instance()
    seed_block.connect("block_on_screen", self, "_on_any_block_on_screen")
    self.add_child(seed_block)

func _on_any_block_on_screen(facsimilie_block):
    var chosen_map = block_cache.get_random_map()
    facsimilie_block.copy_qodot_block(block_cache.map_to_node[chosen_map])
