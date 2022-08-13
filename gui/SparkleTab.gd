extends CenterContainer

# Where do we look for window textures?
# TODO: Add support for "user://" textures
const IN_SPARKLE_TEXTURES = "res://effects/particle_textures/"

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

onready var texture_a = $"%TextureA"
onready var color_a = $"%ColorA"
onready var enabled_a = $"%EnabledA"
onready var size_a = $"%SizeA"
onready var count_a = $"%CountA"
onready var lifetime_a = $"%LifetimeA"
onready var randomness_a = $"%RandomnessA"

onready var texture_b = $"%TextureB"
onready var color_b = $"%ColorB"
onready var enabled_b = $"%EnabledB"
onready var size_b = $"%SizeB"
onready var count_b = $"%CountB"
onready var lifetime_b = $"%LifetimeB"
onready var randomness_b = $"%RandomnessB"

onready var texture_c = $"%TextureC"
onready var color_c = $"%ColorC"
onready var enabled_c = $"%EnabledC"
onready var size_c = $"%SizeC"
onready var count_c = $"%CountC"
onready var lifetime_c = $"%LifetimeC"
onready var randomness_c = $"%RandomnessC"

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

# Loads the possible texture choices from our IN_SPARKLE_TEXTURES directory,
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
    if dir.open(IN_SPARKLE_TEXTURES) != OK:
        print("Couldn't open ", IN_SPARKLE_TEXTURES, "! Can't do anything!!!")
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
                candidate_textures.append(IN_SPARKLE_TEXTURES + file_name)
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
        "sparkle_texture_a":
            var path = mcc.profile_dict[key]
            if path in path_to_id:
                texture_a.select( texture_a.get_item_index( path_to_id[path] ) )
            else:
                print("Can't find item for ", path)
        "sparkle_texture_b":
            var path = mcc.profile_dict[key]
            if path in path_to_id:
                texture_b.select( texture_b.get_item_index( path_to_id[path] ) )
            else:
                print("Can't find item for ", path)
        "sparkle_texture_c":
            var path = mcc.profile_dict[key]
            if path in path_to_id:
                texture_c.select( texture_c.get_item_index( path_to_id[path] ) )
            else:
                print("Can't find item for ", path)
        
        "sparkle_color_a":
            color_a.color = mcc.profile_dict[key]
        "sparkle_color_b":
            color_b.color = mcc.profile_dict[key]
        "sparkle_color_c":
            color_c.color = mcc.profile_dict[key]
        
        "sparkle_enabled_a":
            enabled_a.pressed = mcc.profile_dict[key]
        "sparkle_enabled_b":
            enabled_b.pressed = mcc.profile_dict[key]
        "sparkle_enabled_c":
            enabled_c.pressed = mcc.profile_dict[key]
        
        "sparkle_size_a":
            size_a.value = mcc.profile_dict[key]
        "sparkle_size_b":
            size_b.value = mcc.profile_dict[key]
        "sparkle_size_c":
            size_c.value = mcc.profile_dict[key]
        
        "sparkle_count_a":
            count_a.value = mcc.profile_dict[key]
        "sparkle_count_b":
            count_b.value = mcc.profile_dict[key]
        "sparkle_count_c":
            count_c.value = mcc.profile_dict[key]

        "sparkle_lifetime_a":
            lifetime_a.value = mcc.profile_dict[key]
        "sparkle_lifetime_b":
            lifetime_b.value = mcc.profile_dict[key]
        "sparkle_lifetime_c":
            lifetime_c.value = mcc.profile_dict[key]

        "sparkle_randomness_a":
            randomness_a.value = mcc.profile_dict[key]
        "sparkle_randomness_b":
            randomness_b.value = mcc.profile_dict[key]
        "sparkle_randomness_c":
            randomness_c.value = mcc.profile_dict[key]

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
        mcc.profile_dict["sparkle_texture_a"] = texture_path
        mcc.update_key("sparkle_texture_a")
        
func _on_TextureB_item_selected(index):
    # Get the texture path
    var texture_path = id_to_path[ texture_b.get_selected_id() ]
    
    if _update_global:
        mcc.profile_dict["sparkle_texture_b"] = texture_path
        mcc.update_key("sparkle_texture_b")

func _on_TextureC_item_selected(index):
    # Get the texture path
    var texture_path = id_to_path[ texture_c.get_selected_id() ]
    
    if _update_global:
        mcc.profile_dict["sparkle_texture_c"] = texture_path
        mcc.update_key("sparkle_texture_c")

# ~~~~~~~~~~~~~~~~
#
# Type A
#
# ~~~~~~~~~~~~~~~~
func _on_ColorA_color_changed(color):
    if _update_global:
        mcc.profile_dict["sparkle_color_a"] = color
        mcc.update_key("sparkle_color_a")

func _on_SizeA_value_changed(value):
    if _update_global:
        mcc.profile_dict["sparkle_size_a"] = value
        mcc.update_key("sparkle_size_a")

func _on_CountA_value_changed(value):
    if _update_global:
        mcc.profile_dict["sparkle_count_a"] = value
        mcc.update_key("sparkle_count_a")

func _on_LifetimeA_value_changed(value):
    if _update_global:
        mcc.profile_dict["sparkle_lifetime_a"] = value
        mcc.update_key("sparkle_lifetime_a")

func _on_EnabledA_toggled(button_pressed):
    if _update_global:
        mcc.profile_dict["sparkle_enabled_a"] = button_pressed
        mcc.update_key("sparkle_enabled_a")

func _on_RandomnessA_value_changed(value):
    if _update_global:
        mcc.profile_dict["sparkle_randomness_a"] = value
        mcc.update_key("sparkle_randomness_a")

# ~~~~~~~~~~~~~~~~
#
# Type B
#
# ~~~~~~~~~~~~~~~~
func _on_ColorB_color_changed(color):
    if _update_global:
        mcc.profile_dict["sparkle_color_b"] = color
        mcc.update_key("sparkle_color_b")

func _on_SizeB_value_changed(value):
    if _update_global:
        mcc.profile_dict["sparkle_size_b"] = value
        mcc.update_key("sparkle_size_b")

func _on_CountB_value_changed(value):
    if _update_global:
        mcc.profile_dict["sparkle_count_b"] = value
        mcc.update_key("sparkle_count_b")

func _on_LifetimeB_value_changed(value):
    if _update_global:
        mcc.profile_dict["sparkle_lifetime_b"] = value
        mcc.update_key("sparkle_lifetime_b")

func _on_EnabledB_toggled(button_pressed):
    if _update_global:
        mcc.profile_dict["sparkle_enabled_b"] = button_pressed
        mcc.update_key("sparkle_enabled_b")

func _on_RandomnessB_value_changed(value):
    if _update_global:
        mcc.profile_dict["sparkle_randomness_b"] = value
        mcc.update_key("sparkle_randomness_b")

# ~~~~~~~~~~~~~~~~
#
# Type C
#
# ~~~~~~~~~~~~~~~~
func _on_ColorC_color_changed(color):
    if _update_global:
        mcc.profile_dict["sparkle_color_c"] = color
        mcc.update_key("sparkle_color_c")

func _on_SizeC_value_changed(value):
    if _update_global:
        mcc.profile_dict["sparkle_size_c"] = value
        mcc.update_key("sparkle_size_c")

func _on_CountC_value_changed(value):
    if _update_global:
        mcc.profile_dict["sparkle_count_c"] = value
        mcc.update_key("sparkle_count_c")

func _on_LifetimeC_value_changed(value):
    if _update_global:
        mcc.profile_dict["sparkle_lifetime_c"] = value
        mcc.update_key("sparkle_lifetime_c")

func _on_EnabledC_toggled(button_pressed):
    if _update_global:
        mcc.profile_dict["sparkle_enabled_c"] = button_pressed
        mcc.update_key("sparkle_enabled_c")

func _on_RandomnessC_value_changed(value):
    if _update_global:
        mcc.profile_dict["sparkle_randomness_c"] = value
        mcc.update_key("sparkle_randomness_c")
