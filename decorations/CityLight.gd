extends Spatial

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# Get the MaterialColorControl
onready var mcc = get_node("/root/MaterialColorControl")

# The different light types. We have four different types for four different
# colors.
enum LightCategory {ONE = 1, TWO = 2, THREE = 3, FOUR = 4}

# What type of light is this?
var type = LightCategory.ONE setget set_type

var omni_range = 1 setget set_omni_range

# What's the current light we have stuck under this node?
var _light : OmniLight = null

# TODO: Add an "occurrence rating" to the City Light

# We're able to adjust "effects" by directly manipulating their meshes and
# materials - this is very quick and has an instantaneous effect that is
# replicated across all instances of a node that may use that mesh or material.
# Decorations, on the other hand, exist as individual instances that must be
# manipulated directly. That means, if you have X decorations, you have to make
# X function calls instead of manipulating a resource once. Ergo, manipulating
# decorations is MUCH slower. That's why this node doesn't connect to the MCC's
# key_update signal.

func _ready():
    # If this node isn't visible, back out. No extra processing needed here.
    if not is_visible_in_tree():
        return
    
    # Otherwise, we need to spawn in a light. So, spawn a new omnilight
    _light = OmniLight.new()
    # Add it to the scene
    self.add_child(_light)
    # Force the range
    _light.omni_range = omni_range
    # Perform an MCC update to get the color and other nonsense
    _mcc_update()

func set_type(new_type):
    type = new_type
    
    for group in self.get_groups():
        self.remove_from_group(group)
    
    # Add ourselves to the general light group
    self.add_to_group(GlobalRef.light_group)
    
    match type:
        LightCategory.ONE:
            self.add_to_group(GlobalRef.light_group_one)
        LightCategory.TWO:
            self.add_to_group(GlobalRef.light_group_two)
        LightCategory.THREE:
            self.add_to_group(GlobalRef.light_group_three)
        LightCategory.FOUR:
            self.add_to_group(GlobalRef.light_group_four)
        _:
            pass
    
    _mcc_update()

func set_omni_range(new_range):
    omni_range = new_range

    # If we actually have a light, set the range
    if _light != null:
        _light.omni_range = new_range

# Updates the CityLight to match match the values in the MCC for the light's
# current type.
func _mcc_update():
    # If we don't actually have a light, back out
    if _light == null:
        return
    
    match type:
        LightCategory.ONE:
            _light.light_color = mcc.profile_dict["lights_one_color"]
            _light.visible = mcc.profile_dict["lights_one_visible"]
        LightCategory.TWO:
            _light.light_color = mcc.profile_dict["lights_two_color"]
            _light.visible = mcc.profile_dict["lights_two_visible"]
        LightCategory.THREE:
            _light.light_color = mcc.profile_dict["lights_three_color"]
            _light.visible = mcc.profile_dict["lights_three_visible"]
        LightCategory.FOUR:
            _light.light_color = mcc.profile_dict["lights_four_color"]
            _light.visible = mcc.profile_dict["lights_four_visible"]
        _:
            pass

# The "Total Update" function takes values from the MCC and then applies the
# appropriate position and visual updates. This function is required to avoid
# lagtime when doing enmasse updates.
func total_update():
    # Load MCC values
    _mcc_update()

# When we become visible, we need to either add the light or delete it (as
# appropriate)
func _on_visibility_changed():
    # If we are now visible...
    if self.is_visible_in_tree():
        # Spawn a new omnilight
        _light = OmniLight.new()
        
        # Add it to the scene
        self.add_child(_light)
        
        # Force the range
        _light.omni_range = omni_range
        
        # Perform an MCC update
        _mcc_update()
    
    # Otherwise...
    else:
        # Remove the omnilight
        self.remove_child(_light)
        
        # Queue the light up to be free'd
        _light.queue_free()
        
        # Clear out our _light variable
        _light = null
