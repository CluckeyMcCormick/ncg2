extends Spatial

const MAP_PATH = "res://blocks/trenchbroom_maps/"

# The node-button for our block choice button button thing. It has a long path
# and we use it a lot so we'll just stick it in this variable.
onready var BLOCK_CHOICE_NODE = $GUI/Panel/HBox/VBox/BlockChoiceButton
# Same situation with the Orthogonal Check Box Button.
onready var ORTHO_BOX_NODE = $GUI/Panel/HBox/VBox2/OrthoCheckBox

# Called when the node enters the scene tree for the first time.
func _ready():
    # First, start the camera's eternally circular journey by telling it to
    # always rotate the CameraPivot node 360 degrees.
    $CameraPivot/Tween.interpolate_property(
        $CameraPivot, "rotation_degrees:y", 0, 360, 5,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
    )
    # Start it up!
    $CameraPivot/Tween.start()
    
    # Make sure our GUI matches up with our default values
    $GUI/Panel/HBox/VBox2/HeightSlider.value = $CameraPivot/Camera.translation.y
    $GUI/Panel/HBox/VBox2/FOVSlider.value = $CameraPivot/Camera.fov
    $GUI/Panel/HBox/VBox2/SizeSlider.value = $CameraPivot/Camera.size
    
    # Now we need to dynamically build up our list of blocks we can use. To do
    # so, we're gonna take a look at the blocks directory and see what we can
    # do.
    var dir = Directory.new()
    # If the directory didn't open, then we can't really do anything at all.
    # Ergo, we'll have to back out.
    if dir.open(MAP_PATH) != OK:
        print("Couldn't load TrenchBroom Maps directory! Can't do anything!!!")
        return
    
    # Start the directory-listing-processing thing.
    dir.list_dir_begin(true)
    
    # Get the first file in the directory listing
    var file_name = dir.get_next()
    # While we still have a file...
    while file_name != "":
        # If the current file is NOT a directory...
        if (not dir.current_is_dir()):
            # AND it is a .map file but is NOT a .import file...
            if ".map" in file_name and not (".import" in file_name):
                # Then add it to the choice list!
                BLOCK_CHOICE_NODE.add_item(file_name)
        # Now that we've checked the filename and done any necessary actions,
        # get the next file name.
        file_name = dir.get_next()
    
    # Finish off the directory listing processing... thing.
    dir.list_dir_end()
    
    # Now, get the ID of the selected map. This should be the first one, by
    # default.
    var map_id = BLOCK_CHOICE_NODE.get_selected_id()
    # Now, make a derivative map file using that block-map.
    var new_map = make_derivative(MAP_PATH + BLOCK_CHOICE_NODE.get_item_text(map_id))
    
    # Finally, pass that derivative map into Qodot and rebuild.
    $QodotMap.map_file = ProjectSettings.globalize_path(new_map)
    $QodotMap.verify_and_build()
    
func make_derivative(map_path):
    randomize()
    
    var target_path = "user://block_viewer_cache.map"
    
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
        new_line += " " + str((randi() % 64) * 64 + float(old_line_comp[1]))
        new_line += " " + str((randi() % 64) * 64 + float(old_line_comp[2]))
        new_line += " " + old_line_comp[3]
        new_line += " " + old_line_comp[4]
        new_line += " " + old_line_comp[5]
        out_map.store_line(new_line)

    in_map.close()
    out_map.close()
    
    return target_path

func _on_GoButton_pressed():
    # Get the ID of the selected map. This should be the first one, by
    # default.
    var map_id = BLOCK_CHOICE_NODE.get_selected_id()
    # Now, make a derivative map file using that block-map.
    print(BLOCK_CHOICE_NODE.items[map_id])
    var new_map = make_derivative(MAP_PATH + BLOCK_CHOICE_NODE.get_item_text(map_id))
    
    # Finally, pass that derivative map into Qodot and rebuild.
    $QodotMap.map_file = ProjectSettings.globalize_path(new_map)
    $QodotMap.verify_and_build()

func _on_HeightSlider_value_changed(value):
    $CameraPivot/Camera.translation.y = value

func _on_FOVSlider_value_changed(value):
    $CameraPivot/Camera.fov = value

func _on_SizeSlider_value_changed(value):
    $CameraPivot/Camera.size = value

func _on_OrthoCheckBox_toggled(button_pressed):
    
    $GUI/Panel/HBox/VBox2/FOVSlider.editable = not button_pressed
    $GUI/Panel/HBox/VBox2/SizeSlider.editable = button_pressed
    
    if button_pressed:
        $CameraPivot/Camera.projection = Camera.PROJECTION_ORTHOGONAL
    else:
        $CameraPivot/Camera.projection = Camera.PROJECTION_PERSPECTIVE
    
