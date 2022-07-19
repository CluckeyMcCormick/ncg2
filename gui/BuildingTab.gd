extends Tabs

# Where do we look for window textures?
# TODO: Add support for "user://" textures
const IN_WINDOW_TEXTURES = "res://buildings/textures/"

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

onready var red_picker = $VBox/GridContainer/RedPicker
onready var blue_picker = $VBox/GridContainer/BluePicker
onready var green_picker = $VBox/GridContainer/GreenPicker
onready var building_picker = $VBox/GridContainer/BuildingPicker

# These two dictionaries are used for getting info out of, and updating, the
# TextureSelection GUI element
var id_to_path = {}
var path_to_id = {}

func _ready():
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
        $VBox/TextureSelection.add_item(file_name, id)
        # Track the id to the path and vice versa
        id_to_path[id] = path
        path_to_id[path] = id
        # Increment the id
        id += 1

# Updates the GUI to match what's in the global dictionary
func update_from_global():
    var path = mcc.profile_dict["bld_texture_path"]
    
    # Update the selected path
    if path in path_to_id:
        $VBox/TextureSelection.select(
            $VBox/TextureSelection.get_item_index( path_to_id[path] )
        )
    else:
        print("Can't find item for ", path)
    
    # Get the colors
    red_picker.color = mcc.profile_dict["bld_red_dot"]
    green_picker.color = mcc.profile_dict["bld_green_dot"]
    blue_picker.color = mcc.profile_dict["bld_blue_dot"]
    building_picker.color = mcc.profile_dict["bld_base_color"]
    
    # Update our labels
    $VBox/GridContainer/RedHash.text = "#" + red_picker.color.to_html()
    $VBox/GridContainer/GreenHash.text = "#" + green_picker.color.to_html()
    $VBox/GridContainer/BlueHash.text = "#" + blue_picker.color.to_html()
    $VBox/GridContainer/BuildingHash.text = "#" + building_picker.color.to_html()

# Updates the global dictionary to match what's in the gui, then
func update_to_global():
    # Get the texture path
    var texture_path = id_to_path[ $VBox/TextureSelection.get_selected_id() ]
    
    # Update the relevant dictionary entries
    mcc.profile_dict["bld_texture_path"] = texture_path
    mcc.profile_dict["bld_red_dot"] = red_picker.color
    mcc.profile_dict["bld_green_dot"] = green_picker.color
    mcc.profile_dict["bld_blue_dot"] = blue_picker.color
    mcc.profile_dict["bld_base_color"] = building_picker.color
    
    # Assert the dictionary's values, putting the updated values into practice.
    mcc.dictionary_assert()

func _on_RedPicker_color_changed(color):
    $VBox/GridContainer/RedHash.text = "#" + color.to_html()
    update_to_global()

func _on_GreenPicker_color_changed(color):
    $VBox/GridContainer/GreenHash.text = "#" + color.to_html()
    update_to_global()

func _on_BluePicker_color_changed(color):
    $VBox/GridContainer/BlueHash.text = "#" + color.to_html()
    update_to_global()

func _on_BuildingPicker_color_changed(color):
    $VBox/GridContainer/BuildingHash.text = "#" + color.to_html()
    update_to_global()

func _on_TextureSelection_item_selected(index):
    update_to_global()
