extends VBoxContainer

# Load the DictLoadSave script so we can save and load dictionaries
const DictLoadSave = preload("res://util/DictLoadSave.gd")

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# Emitted whenever we save a file
signal file_saved()

# Grab the MaterialColorControl Node - this will allow us to change some
# variables on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# Called when the node enters the scene tree for the first time.
func _ready():
    # Connect to our own "visibility_changed" signal so we know when we get
    # loaded on screen or not
    self.connect("visibility_changed", self, "_on_visibility_changed")
    
    # Connect to the file name edit node's text changed signal
    $"%FileLine".connect("text_changed", self, "_on_text_changed")
    
    # Connect to the save button's "button pressed" feature
    $"%SaveButton".connect("pressed", self, "_on_button_pressed")

# Called when this node becomes visible. Effectively used to determine when this
# GUI is "popped-up"
func _on_visibility_changed():
    # If we're not visible, back out. We only want to do this processing when we
    # first become visible.
    if not self.visible:
        return
    
    # Disable the button by default. If it SHOULD be enabled, the next step will
    # handle that.
    $"%SaveButton".disabled = true
    
    # Set the text to the MCC value
    $"%FileLine".text = mcc.profile_dict["file_name"]
    
    # Call the text changed function manually
    _on_text_changed( mcc.profile_dict["file_name"] )

# Called whenever the text changes. Verifies the text and enables/disables the
# save button appropriately
func _on_text_changed(new_text):
    # Create a new file so we can see if the user is possibly overwriting
    # something.
    var file = File.new()
    
    # If there's no string, prompt the user 
    if len(new_text) <= 0:
        $InfoLabel.text = "Please enter a .json file name."
        $"%SaveButton".disabled = true
        return
    
    # If the filename is invalid, tell the user
    if not new_text.is_valid_filename():
        $InfoLabel.text = "Please enter a name that doesn't end in whitespace"
        $InfoLabel.text += " and doesn't contain one of the following: "
        $InfoLabel.text += ": / \\ ? * \" | % < >"
        $"%SaveButton".disabled = true
        return
    
    # If it's not a JSON file (regardless of case), tell the user
    if new_text.get_extension().to_lower() != "json":
        $InfoLabel.text = "File must have a .json extension"
        $"%SaveButton".disabled = true
        return
    
    # If we're here, then that's a valid file name! Tell the user.
    $InfoLabel.text = "File name is valid."
    
    # If there's already a file there, tell the user.
    if file.file_exists( GlobalRef.PATH_USER_PROFILES + new_text ):
        $InfoLabel.text += " Existing file will be overwritten!"
    
    # Enable the save button!
    $"%SaveButton".disabled = false

func _on_button_pressed():
    # We're gonna stick the filepath in here, because it might just be a bit
    # long
    var path
    
    # Set the file name in the mcc
    # There's something kind of heretical about using a text value scraped from
    # a GUI at the moment you're saving a file... but I'm lazy.
    mcc.profile_dict["file_name"] = $"%FileLine".text
    
    # Craft the path
    path = GlobalRef.PATH_USER_PROFILES + mcc.profile_dict["file_name"]
    
    # Try and save - if the save is successful...
    if DictLoadSave.save_dict(path, mcc.profile_dict):
        # Tell the user we saved
        $InfoLabel.text = "FILE SAVED!!!"
        
        # Tell EVERYONE that we saved
        emit_signal("file_saved")
    
    # Otherwise...
    else:
        # Tell the user we failed
        $InfoLabel.text = "Could not save file due to error, try checking logs."

    # Tell all MCC classes the filename got updated
    mcc.update_key("file_name")
