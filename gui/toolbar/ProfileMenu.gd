extends MenuButton

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# Load the Directory Resource finder so we can easily load file directly
const DRFinder = preload("res://util/DirectoryResourceFinder.gd")

# Load the DictLoadSave script so we can save and load dictionaries
const DictLoadSave = preload("res://util/DictLoadSave.gd")

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# The default profiles. We specify these by hand instead of manually discovering
# them because we want them in a very particular order.
var default_profiles = [
    "res://profiles/Niteflyte.tres", "res://profiles/Velvet.tres",
    "res://profiles/5AM.tres", "res://profiles/Sailor.tres",
    "res://profiles/TWA.tres", "res://profiles/FairyFlossDark.tres",
    "res://profiles/BadMoon.tres", "res://profiles/FunkyFuture8.tres"
]

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# This dictionary converts a PopupMenu ID to a loaded resource.
var id_to_res = {}

# Popup menu ID for the profile reload button. Triggers a reload of the
# profiles.
var reload_id = -1
# Popup menu ID for the edit metadata button. Opens a metadata edit menu
var edit_id = -1
# Popup menu ID for the save profile button. Opens a save menu.
var save_id= -1

# What's the current id for the currently "selected" profile?
var current_id = 0

func _ready():
    # First, get the pop-up menu
    var popup = self.get_popup()
    # Connect to the id_pressed signal so we know when the user did something.
    popup.connect("id_pressed", self, "_on_popup_id_pressed")
    # Rebuild the menu
    _build_menu()

func assert_profile():
    # If this is a dictionary, then this was a user profile. In that case...
    if typeof(id_to_res[current_id]) == TYPE_DICTIONARY:
        # Iterate over the keys in the user's dictionary...
        for key in id_to_res[current_id]:
            # If this key isn't present in the profile dictionary, that likely
            # means it was an older key. In that case, we want to skip it.
            if not key in mcc.profile_dict:
                continue
            
            # Otherwise, this is a valid key! Set the value in the profile. This
            # "piecemeal" setting style ensures that any "missed" keys will
            # retain their old values.
            mcc.profile_dict[key] = id_to_res[current_id][key]
    # Otherwise...
    else:
        # This is a standardized profile resource, so just set the dictionary
        # directly using the profile.
        mcc.profile_dict = id_to_res[current_id].to_dict()
    
    # Update the whole dictionary
    mcc.update_whole_dictionary()
    
    mcc.regenerate_texture_a()
    mcc.regenerate_texture_b()
    mcc.regenerate_texture_c()

func _build_menu():
    # What are the paths to our user profiles?
    var user_profiles = []
    # What's the current file we're looking at?
    var file_name
    # What's the current id for the items we're adding? We need to assign these
    # manually so we can easily get to them.
    var id = 0
    # Temp variable; used to hold a loaded resource.
    var res
    
    # Now we need to dynamically build up our list of profiles we can use. To do
    # so, we're gonna take a look at the profiles directory and see what we can
    # do.
    var dir = Directory.new()
    
    # To load a user profile, we'll also need a file object
    var file = File.new()
    
    # Get our popup too
    var popup = self.get_popup()
    
    #
    # Step 1: Clean up
    #
    id_to_res.clear()
    popup.clear()
    
    #
    # Step 2: Find user profiles
    #
    user_profiles = DRFinder.get_path_resources(
        GlobalRef.PATH_USER_PROFILES, ".json"
    )
    
    #
    # Step 3: Build menu - default profiles
    #
    # First load the default profiles.
    for profile_path in default_profiles:
        # Load the resource
        res = load(profile_path)
        
        # If we couldn't load this resource, skip it.
        if res == null:
            print("Couldn't load default profile: ", profile_path)
            continue
        
        # Add this profile as an item
        popup.add_item(res.profile_name, id)
        
        # Track the id to the resource
        id_to_res[id] = res
        
        # Increment the id
        id += 1
    
    #
    # Step 4: Build menu - user profiles
    #
    # Add a separator between the default and user profiles
    if len(user_profiles) > 0:
        popup.add_separator("", id)
        id += 1
    
    # Next load the user profiles
    for profile_path in user_profiles:
        # Get the dictionary from the JSON file
        res = DictLoadSave.load_dict(profile_path)
        
        # If this dictionary is empty, skip it!
        if res.empty():
            continue
        
        # Add this profile as an item
        popup.add_item( res["profile_name"], id )
        
        # Track the id to the resource
        id_to_res[id] = res
        
        # Increment the id
        id += 1
    
    #
    # Step 5: Build menu - fixed options
    #
    # Add a separator between the profiles and the functional menu items
    popup.add_separator("", id)
    id += 1
    # Add a "reload" item
    reload_id = id
    popup.add_item("Reload Profiles", id)
    id += 1
    # Add a "edit" item
    edit_id = id
    popup.add_item("Edit Profile Metadata", id)
    id += 1
    # Add a "save" item
    save_id = id
    popup.add_item("Save Current Profile", id)
    id += 1

func _on_popup_id_pressed(id):
    # If this is the reload menu item, rebuild the menu items
    if reload_id == id:
        _build_menu()
    # If this is the edit menu item, open the edit menu
    elif edit_id == id:
        $ProfileDialog.popup_centered_minsize()
    # If this is the save menu item, open the save menu
    elif save_id == id:
        $SavefileDialog.popup_centered_minsize()
    # Otherwise...
    else:
        # This must be a profile. Set the current ID...
        current_id = id
        # Assert the profile!
        assert_profile()

# When a file is saved, rebuild the menu. We want to see if we can load whatever
# the user profile was.
func _on_SaveControl_file_saved():
    _build_menu()
