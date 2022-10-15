extends Node

# ~~~~~~~~~~~~~~~~
#
# Resource Loads
#
# ~~~~~~~~~~~~~~~~

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# ~~~~~~~~~~~~~~~~
#
#  Variables
#
# ~~~~~~~~~~~~~~~~

# BUGREPORT: These exist just for tracking the CityLights/Omnilights
var overall_lights = 0
var visible_lights = 0

# Are we currently performing a mass update? This is needed to optimize how we
# update decorations
var _mass_update = false

# The dictionary that makes up our profile object
var profile_dict = {}

# ~~~~~~~~~~~~~~~~
#
# Signals
#
# ~~~~~~~~~~~~~~~~
signal key_update(key)

# ~~~~~~~~~~~~~~~~
#
# Functions
#
# ~~~~~~~~~~~~~~~~

func _ready():
    profile_dict["lights_one_color"] = Color.red
    profile_dict["lights_one_visible"] = true
    
    profile_dict["lights_two_color"] = Color.blue
    profile_dict["lights_two_visible"] = true
    
    profile_dict["lights_three_color"] = Color.green
    profile_dict["lights_three_visible"] = true
    
    profile_dict["lights_four_color"] = Color.yellow
    profile_dict["lights_four_visible"] = true

# Asserts the current values into the dictionary
func update_whole_dictionary():
    # We're now doing a MASS UPDATE
    _mass_update = true
    
    # For each key, do an update.
    for key in profile_dict.keys():
        update_key(key)
    
    # Now we need to call the "total update" functions on all of our groups -
    # this SHOULD save us from queuing multiple redundant calls.
    
    # Lights
    get_tree().call_group(GlobalRef.light_group, "total_update")
    
    # Mass update complete!
    _mass_update = false

# Some of the keys above have special processing when their values are updated.
# Rather than performing all the special processing actions all at once, we have
# this function - it will perform only the special processing actions for the
# given key. This allows us to perform updates piecemeal.
func update_key(key):
    match key:
        #
        # Lights
        #
        "lights_one_color", "lights_one_visible":
            if _mass_update:
                continue
            get_tree().call_group(GlobalRef.light_group_one, "_mcc_update")
        "lights_two_color", "lights_two_visible":
            if _mass_update:
                continue
            get_tree().call_group(GlobalRef.light_group_two, "_mcc_update")
        "lights_three_color", "lights_three_visible":
            if _mass_update:
                continue
            get_tree().call_group(GlobalRef.light_group_three, "_mcc_update")
        "lights_four_color", "lights_four_visible":
            if _mass_update:
                continue
            get_tree().call_group(GlobalRef.light_group_four, "_mcc_update")
    
    # Tell everyone that we're updating
    emit_signal("key_update", key)
