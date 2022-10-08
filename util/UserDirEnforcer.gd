extends Node

# This node ensures the user:// directory has the appropriate subdirectories, so
# we can save and load custom content at will.

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

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
    
    # Open the user path - this is necessary for us to create the subdirectories
    dir.open(GlobalRef.PATH_USER)
    
    # For each subdirectory...
    for subdir in GlobalRef.PATH_USER_MANIFEST:
        # If the subdirectory exists...
        if dir.dir_exists(subdir):
            continue
        
        # If we're here, this subdirectory doesn't exist - time to make it!
        result = dir.make_dir_recursive(subdir)
        
        # If we got an error, tell the user
        if result:
            printerr(
                "Couldn't make subdirectory %! Error code %" % [result, subdir]
            )
    
