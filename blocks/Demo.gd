extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    var maps = $BlockCache.get_all_resource_maps()
    $BlockCache.make_blockenstein(maps)
    $BlockCache.build_blockensteins()
