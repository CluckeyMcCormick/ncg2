extends OmniLight

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

# TODO: Add an "occurrence rating" to the City Light

# We're able to adjust "effects" by directly manipulating their meshes and
# materials - this is very quick and has an instantaneous effect that is
# replicated across all instances of a node that may use that mesh or material.
# Decorations, on the other hand, exist as individual instances that must be
# manipulated directly. That means, if you have X decorations, you have to make
# X function calls instead of manipulating a resource once. Ergo, manipulating
# decorations is MUCH slower. That's why this node doesn't connect to the MCC's
# key_update signal.

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

# Updates the CityLight to match match the values in the MCC for the light's
# current type.
func _mcc_update():
    match type:
        LightCategory.ONE:
            light_color = mcc.profile_dict["lights_one_color"]
            visible = mcc.profile_dict["lights_one_visible"]
        LightCategory.TWO:
            light_color = mcc.profile_dict["lights_two_color"]
            visible = mcc.profile_dict["lights_two_visible"]
        LightCategory.THREE:
            light_color = mcc.profile_dict["lights_three_color"]
            visible = mcc.profile_dict["lights_three_visible"]
        LightCategory.FOUR:
            light_color = mcc.profile_dict["lights_four_color"]
            visible = mcc.profile_dict["lights_four_visible"]
        _:
            pass

# The "Total Update" function takes values from the MCC and then applies the
# appropriate position and visual updates. This function is required to avoid
# lagtime when doing enmasse updates.
func total_update():
    # Load MCC values
    _mcc_update()
