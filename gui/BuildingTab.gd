extends VBoxContainer

# Where do we look for window textures?
# TODO: Add support for "user://" textures
const IN_WINDOW_TEXTURES = "res://buildings/textures/"

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

onready var red_picker = $"%RedPicker"
onready var red_spinner = $"%RedSpinner"
onready var blue_picker = $"%BluePicker"
onready var blue_spinner = $"%BlueSpinner"
onready var green_picker = $"%GreenPicker"
onready var green_spinner = $"%GreenSpinner"
onready var building_picker = $"%BuildingPicker"
onready var texture_picker = $"%TextureSelection"

# These two dictionaries are used for getting info out of, and updating, the
# TextureSelection GUI element
var id_to_path = {}
var path_to_id = {}

# Do we update the global profile to reflect our values whenever a value gets
# updated?
var _update_global = true

func _ready():
    # Connect to the key update signal, so we can respond to key changes.
    mcc.connect("key_update", self, "_on_mcc_key_update")
    # Initialize our texture choices.
    load_texture_choices()

# Loads the possible texture choices from our IN_WINDOW_TEXTURES directory,
# loading the choices into the GUI
func load_texture_choices():
    # What are the paths to our different textures?
    var candidate_textures = []
    # What's the current file we're looking at?
    var file_name
    # What's the current id for what we're putting in our texture selection? We
    # need to assign these manually so we can easily get to them.
    var id = 0
    
    # Now we need to dynamically build up our list of blocks we can use. To do
    # so, we're gonna take a look at the blocks directory and see what we can
    # do.
    var dir = Directory.new()
    
    # If the directory didn't open, then we can't really do anything at all.
    # Ergo, we'll have to back out.
    if dir.open(IN_WINDOW_TEXTURES) != OK:
        print("Couldn't open ", IN_WINDOW_TEXTURES, "! Can't do anything!!!")
        return
    
    # Start the directory-listing-processing thing.
    dir.list_dir_begin(true)
    
    # Get the first file in the directory listing
    file_name = dir.get_next()
    # While we still have a file...
    while file_name != "":
        # If the current file is NOT a directory...
        if (not dir.current_is_dir()):
            # AND it is a .png file but is NOT a .import file...
            if ".png" in file_name and not (".import" in file_name):
                # Then add it to the choice list!
                candidate_textures.append(IN_WINDOW_TEXTURES + file_name)
        # Now that we've checked the filename and done any necessary actions,
        # get the next file name.
        file_name = dir.get_next()
    
    # Finish off the directory listing processing... thing.
    dir.list_dir_end()
    
    # Sort the textures so the names are alphabetical
    candidate_textures.sort()
    
    # For each path...
    for path in candidate_textures:
        # Get the file name, captialized
        file_name = path.get_file().get_basename().capitalize()
        # Stick it in the textures selection area
        texture_picker.add_item(file_name, id)
        # Track the id to the path and vice versa
        id_to_path[id] = path
        path_to_id[path] = id
        # Increment the id
        id += 1

func _on_mcc_key_update(key):
    # Disable updating the globabl dictionary - we don't want to update
    # something while we're reading from it!
    _update_global = false
    
    match key:
        #
        # Building
        #
        "bld_red_dot":
            red_picker.color = mcc.profile_dict[key]
        "bld_red_mixer":
            red_spinner.value = mcc.profile_dict[key]
        "bld_green_dot":
            green_picker.color = mcc.profile_dict[key]
        "bld_green_mixer":
            green_spinner.value = mcc.profile_dict[key]
        "bld_blue_dot":
            blue_picker.color = mcc.profile_dict[key]
        "bld_blue_mixer":
            blue_spinner.value = mcc.profile_dict[key]
        "bld_base_color":
            building_picker.color = mcc.profile_dict[key]
        "bld_texture_path":
            var path = mcc.profile_dict[key]
            
            # Update the selected path
            if path in path_to_id:
                texture_picker.select(
                    texture_picker.get_item_index( path_to_id[path] )
                )
            else:
                print("Can't find item for ", path)

    # Re-enable updating the global dictionary.
    _update_global = true

func _on_RedPicker_color_changed(color):
    if _update_global:
        mcc.profile_dict["bld_red_dot"] = color
        mcc.update_key("bld_red_dot")

func _on_RedSpinner_value_changed(value):
    if _update_global:
        mcc.profile_dict["bld_red_mixer"] = value
        mcc.update_key("bld_red_mixer")

func _on_GreenPicker_color_changed(color):
    if _update_global:
        mcc.profile_dict["bld_green_dot"] = color
        mcc.update_key("bld_green_dot")

func _on_GreenSpinner_value_changed(value):
    if _update_global:
        mcc.profile_dict["bld_green_mixer"] = value
        mcc.update_key("bld_green_mixer")

func _on_BluePicker_color_changed(color):
    if _update_global:
        mcc.profile_dict["bld_blue_dot"] = color
        mcc.update_key("bld_blue_dot")

func _on_BlueSpinner_value_changed(value):
    if _update_global:
        mcc.profile_dict["bld_blue_mixer"] = value
        mcc.update_key("bld_blue_mixer")

func _on_BuildingPicker_color_changed(color):
    if _update_global:
        mcc.profile_dict["bld_base_color"] = color
        mcc.update_key("bld_base_color")

func _on_TextureSelection_item_selected(index):
    # Get the texture path
    var texture_path = id_to_path[ texture_picker.get_selected_id() ]
    
    if _update_global:
        mcc.profile_dict["bld_texture_path"] = texture_path
        mcc.update_key("bld_texture_path")
