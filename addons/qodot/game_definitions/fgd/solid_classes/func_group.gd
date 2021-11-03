extends Spatial

export(Dictionary) var properties setget set_properties

var block_name = ""
var group_id = ""
var max_height = -1
var min_height = max_height - 1
var voronoi_pattern = ""

func set_properties(new_properties: Dictionary) -> void:
    if properties != new_properties:
        properties = new_properties
        update_properties()

func update_properties() -> void:
    
    if "_tb_name" in properties:
        block_name = properties._tb_name
        
    if "_tb_id" in properties:
        group_id = properties._tb_id
        self.add_to_group(group_id, true)
        print("Added group_id: ", group_id)
    
    if "max_height" in properties:
        max_height = properties.max_height
        
    if "min_height" in properties:
        min_height = properties.min_height
        
    if "voronoi_pattern" in properties:
        voronoi_pattern = properties.voronoi_pattern

func _init() -> void:
    pass

func _enter_tree() -> void:
    if self.group_id != "":
        pass
    pass

func _process(delta: float) -> void:
    pass
