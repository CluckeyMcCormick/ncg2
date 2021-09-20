extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    $CameraPivot/Tween.interpolate_property(
        $CameraPivot, "rotation_degrees:y", 0, 360, 5,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
    )
    $CameraPivot/Tween.start()
    
    randomize()
    
    var new_map = make_derivative("res://blocks/trenchbroom_maps/block01.map")
    print(ProjectSettings.globalize_path(new_map))
    $QodotMap.map_file = ProjectSettings.globalize_path(new_map)
    $QodotMap.verify_and_build()
    
func make_derivative(map_path):
    var target_path = "user://blk_drv_"
    target_path += map_path.get_file().get_basename() + "_01"
    target_path += "." + map_path.get_extension()
    
    var in_map = File.new()
    in_map.open(map_path, File.READ)
    var out_map = File.new()
    out_map.open(target_path, File.WRITE)
    
    while not in_map.eof_reached():
        var line = in_map.get_line()
        var keyword_index = line.find("building_horizontal_window")
        
        if keyword_index == -1:
            out_map.store_line(line)
            continue
        
        var new_line = line.substr(0, keyword_index)
        var old_line_comp = line.substr(keyword_index).split(" ", false)
        
        new_line += old_line_comp[0]
        new_line += " " + str((randi() % 64) * 64)
        new_line += " " + str((randi() % 64) * 64)
        new_line += " " + old_line_comp[3]
        new_line += " " + old_line_comp[4]
        new_line += " " + old_line_comp[5]
        out_map.store_line(new_line)

    in_map.close()
    out_map.close()
    
    return target_path
