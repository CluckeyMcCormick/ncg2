extends Node

# This node ensures the user:// directory has the appropriate subdirectories, so
# we can save and load custom content at will.

# What directories are we trying to create? These are all going to be under the
# user:// directory/path.
const DIRS = [
    "profiles", "mods", "textures/antennae", "textures/particle",
    "textures/moon", "textures/windows"
]

# Function called when this node enters the scene.
func _ready():
    enforce_dirs()

# Function that actually creates the directories. Having this as a function
# allows us to enforce the directories whenever and wherever we please.
func enforce_dirs():
    # Result value; should be an Error type
    var result
    
    # Create a new directory object
    var dir = Directory.new()
    
    # Open the user directory.
    dir.open("user://")
    
    # For each subdirectory...
    for subdir in DIRS:
        # If the subdirectory exists...
        if dir.dir_exists(subdir):
            continue
        
        # If we're here, this subdirectory doesn't exist - time to make it!
        result = dir.make_dir_recursive(subdir)
        
        # If we got an error, tell the user
        match result:
            OK:
                continue
            _:
                printerr(
                    "Couldn't make subdirectory ", subdir,
                    "! Error code ", result
                )
