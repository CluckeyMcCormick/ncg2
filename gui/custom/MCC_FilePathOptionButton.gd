extends OptionButton
class_name MCCFilePathOptionButton

# TODO: Implement some sort of global cache, where resources loaded are stored
# in arrays. These arrays are then accessed with a given directory path. We
# would need a reload function capable of ignoring the global cache.

# Utility script to find resources
const DIR_RES_FIND = preload("res://util/DirectoryResourceFinder.gd")

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# What's the Material Color Control Key property we're targeting?
export(String) var target_key

# What's the default directory we're targeting?
export(String) var default_directory
# What's the extension we're looking for on files in the default directory?
export(String) var default_extension

# What's the user directory we're targeting?
export(String) var user_directory
# What's the extension we're looking for on files in the user directory?
export(String) var user_extension

# Do we update the global profile to reflect our values whenever a value gets
# updated? We need this to stop ourselves from accidentally looping forever.
var _update_global = true

# These two dictionaries are used for getting info out of, and updating, the
# texture selection GUI elements
var id_to_path = {}
var path_to_id = {}

func _ready():
    # What's the current file we're looking at?
    var file_name
    # What's the our current list of resources? Mind you this isn't necessarily
    # a captial-R Resource - just a file path of some kind
    var resources
    # What's the current id for what we're putting in our texture selection? We
    # need to assign these manually so we can easily get to them.
    var id = 0
    
    # Connect to the key update signal, so we can respond to key changes.
    mcc.connect("key_update", self, "_on_mcc_key_update")
    # Connect to our own "item_selected" signal. We do this in code to ensure
    # the user doesn't accidentally disconnect the signal when including this in
    # a scene.
    self.connect("item_selected", self, "_on_item_selected")
    
    # Get a list of the paths-to-be-found in the configured directory (with the
    # appropriate extension, of course).
    resources = DIR_RES_FIND.get_path_resources(
        default_directory, default_extension
    )

    # TODO: add support for user directories

    # Sort the textures so the names are alphabetical
    resources.sort()
    
    # For each path...
    for path in resources:
        # Get the file name, captialized
        file_name = path.get_file().get_basename().capitalize()
        # Stick it in the selection areas
        self.add_item(file_name, id)
        # Track the id to the path and vice versa
        id_to_path[id] = path
        path_to_id[path] = id
        # Increment the id
        id += 1

func _on_mcc_key_update(key):
    # Disable updating the globabl dictionary - we don't want to update
    # something while we're reading from it!
    _update_global = false
    
    # The path as given by the key
    var path
    
    # Update only if our key matches.
    match key:
        target_key:
            path = mcc.profile_dict[key]
            if path in path_to_id:
                self.select( self.get_item_index( path_to_id[path] ) )
            else:
                print("Can't find item for ", path)

    # Enable global updating again
    _update_global = true

func _on_item_selected(color):
    # Get the path
    var path = id_to_path[ self.get_selected_id() ]
    
    if _update_global:
        mcc.profile_dict[target_key] = path
        mcc.update_key(target_key)

