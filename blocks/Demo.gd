extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    var maps = $BlockCache.get_all_resource_maps()
    $BlockCache.make_blockenstein(maps)
    
    # Give it the path to the map
    $QodotMap.map_file = ProjectSettings.globalize_path($BlockCache.OUT_MAP_PATH + "blockenstein.map")
    $QodotMap.verify_and_build()
    
    #var nodes = get_tree().get_nodes_in_group("1")
    #for n in nodes:
        #print(n)
    #pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
