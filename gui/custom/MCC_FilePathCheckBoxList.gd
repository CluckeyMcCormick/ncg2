extends ScrollContainer

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

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

# Used to corroborate file paths to CheckBox nodes 
var path_to_node = {}

# Used as a Set-like container to determine which paths are and aren't selected.
var selected_paths = {}

func _ready():
    # What's the current file we're looking at?
    var file_name
    # What's the our current list of resources? Mind you this isn't necessarily
    # a captial-R Resource - just a file path of some kind
    var resources
    # A CheckBox node that we create 
    var check_box
    
    # Connect to the key update signal, so we can respond to key changes.
    mcc.connect("key_update", self, "_on_mcc_key_update")
    
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
        # Create a new check box control node
        check_box = CheckBox.new()
        # Set the text of the check box to our concocted filename
        check_box.text = file_name
        # Stick it in the selection areas
        $FlowBox.add_child(check_box)
        # Track the path to the node
        path_to_node[path] = check_box
        
        # Manually connect to the check box's toggled signal
        check_box.connect("toggled", self, "_on_CheckBox_toggled", [path])

func _clear():
    for checkbox in $FlowBox.get_children():
        checkbox.pressed = false

func _on_mcc_key_update(key):
    # Disable updating the globabl dictionary - we don't want to update
    # something while we're reading from it!
    _update_global = false
    
    # Update only if our key matches.
    match key:
        target_key:
            # Clear our current selection
            _clear()
            selected_paths.clear()
            
            # For each path in our target dictionary, press the checkbox. For
            # a checkbox, setting the "pressed" property triggers the "toggled"
            # signal, so this will update the selected_paths dictionary
            for path in mcc.profile_dict[key]:
                path_to_node[path].pressed = true

    # Enable global updating again
    _update_global = true

func _on_CheckBox_toggled(button_pressed, path):
    if button_pressed:
        selected_paths[path] = path
    else:
        selected_paths.erase(path)
    
    if _update_global:
        mcc.profile_dict[target_key] = selected_paths.keys()
        mcc.update_key(target_key)
