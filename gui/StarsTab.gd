extends VBoxContainer

# Where do we look for window textures?
# TODO: Add support for "user://" textures
const IN_STAR_TEXTURES = "res://effects/particle_textures/"

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

onready var picker_a = $HBoxTypeA/ColorPickerButtonA
onready var option_a = $HBoxTypeA/OptionButtonA

onready var picker_b = $HBoxTypeB/ColorPickerButtonB
onready var option_b = $HBoxTypeB/OptionButtonB

onready var picker_c = $HBoxTypeC/ColorPickerButtonC
onready var option_c = $HBoxTypeC/OptionButtonC

# These two dictionaries are used for getting info out of, and updating, the
# star selection GUI elements
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

# Loads the possible texture choices from our IN_STAR_TEXTURES directory,
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
    if dir.open(IN_STAR_TEXTURES) != OK:
        print("Couldn't open ", IN_STAR_TEXTURES, "! Can't do anything!!!")
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
                candidate_textures.append(IN_STAR_TEXTURES + file_name)
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
        # Stick it in the selection areas
        option_a.add_item(file_name, id)
        option_b.add_item(file_name, id)
        option_c.add_item(file_name, id)
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
        # Stars
        #
        "stars_type_a_texture":
            var path = mcc.profile_dict[key]
            if path in path_to_id:
                option_a.select( option_a.get_item_index( path_to_id[path] ) )
            else:
                print("Can't find item for ", path)
        "stars_type_b_texture":
            var path = mcc.profile_dict[key]
            if path in path_to_id:
                option_b.select( option_b.get_item_index( path_to_id[path] ) )
            else:
                print("Can't find item for ", path)
        "stars_type_c_texture":
            var path = mcc.profile_dict[key]
            if path in path_to_id:
                option_c.select( option_c.get_item_index( path_to_id[path] ) )
            else:
                print("Can't find item for ", path)
        "stars_type_a_color":
            picker_a.color = mcc.profile_dict[key]
        "stars_type_b_color":
            picker_b.color = mcc.profile_dict[key]
        "stars_type_c_color":
            picker_c.color = mcc.profile_dict[key]

    # Re-enable updating the global dictionary.
    _update_global = true

func _on_ColorPickerButtonA_color_changed(color):
    if _update_global:
        mcc.profile_dict["stars_type_a_color"] = color
        mcc.update_key("stars_type_a_color")

func _on_ColorPickerButtonB_color_changed(color):
    if _update_global:
        mcc.profile_dict["stars_type_b_color"] = color
        mcc.update_key("stars_type_b_color")

func _on_ColorPickerButtonC_color_changed(color):
    if _update_global:
        mcc.profile_dict["stars_type_c_color"] = color
        mcc.update_key("stars_type_c_color")

func _on_OptionButtonA_item_selected(index):
    # Get the texture path
    var texture_path = id_to_path[ option_a.get_selected_id() ]
    
    if _update_global:
        mcc.profile_dict["stars_type_a_texture"] = texture_path
        mcc.update_key("stars_type_a_texture")

func _on_OptionButtonB_item_selected(index):
    # Get the texture path
    var texture_path = id_to_path[ option_b.get_selected_id() ]
    
    if _update_global:
        mcc.profile_dict["stars_type_b_texture"] = texture_path
        mcc.update_key("stars_type_b_texture")

func _on_OptionButtonC_item_selected(index):
    # Get the texture path
    var texture_path = id_to_path[ option_c.get_selected_id() ]
    
    print("Updating Texture C")
    
    if _update_global:
        mcc.profile_dict["stars_type_c_texture"] = texture_path
        mcc.update_key("stars_type_c_texture")
