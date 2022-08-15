extends VBoxContainer

# Where do we look for window textures?
# TODO: Add support for "user://" textures
const IN_BEACON_TEXTURES = "res://effects/particle_textures/"

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

onready var texture_a = $"%TextureA"
onready var color_a = $"%ColorA"
onready var size_a = $"%SizeA"
onready var correction_a = $"%CorrectionA"

onready var texture_b = $"%TextureB"
onready var color_b = $"%ColorB"
onready var size_b = $"%SizeB"
onready var correction_b = $"%CorrectionB"

onready var texture_c = $"%TextureC"
onready var color_c = $"%ColorC"
onready var size_c = $"%SizeC"
onready var correction_c = $"%CorrectionC"

onready var min_height = $"%BuildingHeight"
onready var enabled = $"%BeaconEnabled"

# These two dictionaries are used for getting info out of, and updating, the
# texture selection GUI elements
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

# Loads the possible texture choices from our IN_BEACON_TEXTURES directory,
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
    if dir.open(IN_BEACON_TEXTURES) != OK:
        print("Couldn't open ", IN_BEACON_TEXTURES, "! Can't do anything!!!")
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
                candidate_textures.append(IN_BEACON_TEXTURES + file_name)
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
        texture_a.add_item(file_name, id)
        texture_b.add_item(file_name, id)
        texture_c.add_item(file_name, id)
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
        "beacon_texture_a":
            var path = mcc.profile_dict[key]
            if path in path_to_id:
                texture_a.select( texture_a.get_item_index( path_to_id[path] ) )
            else:
                print("Can't find item for ", path)
        "beacon_texture_b":
            var path = mcc.profile_dict[key]
            if path in path_to_id:
                texture_b.select( texture_b.get_item_index( path_to_id[path] ) )
            else:
                print("Can't find item for ", path)
        "beacon_texture_c":
            var path = mcc.profile_dict[key]
            if path in path_to_id:
                texture_c.select( texture_c.get_item_index( path_to_id[path] ) )
            else:
                print("Can't find item for ", path)
        
        
        "beacon_color_a":
            color_a.color = mcc.profile_dict[key]
        "beacon_color_b":
            color_b.color = mcc.profile_dict[key]
        "beacon_color_c":
            color_c.color = mcc.profile_dict[key]
        
        
        "beacon_size_a":
            size_a.value = mcc.profile_dict[key]
        "beacon_size_b":
            size_b.value = mcc.profile_dict[key]
        "beacon_size_c":
            size_c.value = mcc.profile_dict[key]
        
        
        "beacon_correction_a":
            correction_a.value = mcc.profile_dict[key]
        "beacon_correction_b":
            correction_b.value = mcc.profile_dict[key]
        "beacon_correction_c":
            correction_c.value = mcc.profile_dict[key]
        
        
        "beacon_height":
            min_height.value = mcc.profile_dict[key]
        "beacon_enabled":
            enabled.pressed = mcc.profile_dict[key]

    # Re-enable updating the global dictionary.
    _update_global = true

# ~~~~~~~~~~~~~~~~
#
# Texture Selections
#
# ~~~~~~~~~~~~~~~~
func _on_TextureA_item_selected(index):
    # Get the texture path
    var texture_path = id_to_path[ texture_a.get_selected_id() ]
    
    if _update_global:
        mcc.profile_dict["beacon_texture_a"] = texture_path
        mcc.update_key("beacon_texture_a")
        
func _on_TextureB_item_selected(index):
    # Get the texture path
    var texture_path = id_to_path[ texture_b.get_selected_id() ]
    
    if _update_global:
        mcc.profile_dict["beacon_texture_b"] = texture_path
        mcc.update_key("beacon_texture_b")

func _on_TextureC_item_selected(index):
    # Get the texture path
    var texture_path = id_to_path[ texture_c.get_selected_id() ]
    
    if _update_global:
        mcc.profile_dict["beacon_texture_c"] = texture_path
        mcc.update_key("beacon_texture_c")

# ~~~~~~~~~~~~~~~~
#
# Type A
#
# ~~~~~~~~~~~~~~~~
func _on_ColorA_color_changed(color):
    if _update_global:
        mcc.profile_dict["beacon_color_a"] = color
        mcc.update_key("beacon_color_a")

func _on_SizeA_value_changed(value):
    if _update_global:
        mcc.profile_dict["beacon_size_a"] = value
        mcc.update_key("beacon_size_a")

func _on_CorrectionA_value_changed(value):
    if _update_global:
        mcc.profile_dict["beacon_correction_a"] = value
        mcc.update_key("beacon_correction_a")

# ~~~~~~~~~~~~~~~~
#
# Type B
#
# ~~~~~~~~~~~~~~~~
func _on_ColorB_color_changed(color):
    if _update_global:
        mcc.profile_dict["beacon_color_b"] = color
        mcc.update_key("beacon_color_b")

func _on_SizeB_value_changed(value):
    if _update_global:
        mcc.profile_dict["beacon_size_b"] = value
        mcc.update_key("beacon_size_b")

func _on_CorrectionB_value_changed(value):
    if _update_global:
        mcc.profile_dict["beacon_correction_b"] = value
        mcc.update_key("beacon_correction_b")

# ~~~~~~~~~~~~~~~~
#
# Type C
#
# ~~~~~~~~~~~~~~~~
func _on_ColorC_color_changed(color):
    if _update_global:
        mcc.profile_dict["beacon_color_c"] = color
        mcc.update_key("beacon_color_c")

func _on_SizeC_value_changed(value):
    if _update_global:
        mcc.profile_dict["beacon_size_c"] = value
        mcc.update_key("beacon_size_c")

func _on_CorrectionC_value_changed(value):
    if _update_global:
        mcc.profile_dict["beacon_correction_c"] = value
        mcc.update_key("beacon_correction_c")

# ~~~~~~~~~~~~~~~~
#
# Miscellaneous
#
# ~~~~~~~~~~~~~~~~
func _on_BuildingHeight_value_changed(value):
    if _update_global:
        mcc.profile_dict["beacon_height"] = value
        mcc.update_key("beacon_height")

func _on_BeaconEnabled_toggled(button_pressed):
    if _update_global:
        mcc.profile_dict["beacon_enabled"] = button_pressed
        mcc.update_key("beacon_enabled")


