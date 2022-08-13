extends GridContainer

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

onready var one_picker = $"%OnePicker"
onready var two_picker = $"%TwoPicker"
onready var three_picker = $"%ThreePicker"
onready var four_picker = $"%FourPicker"

onready var one_check = $"%OneCheck"
onready var two_check = $"%TwoCheck"
onready var three_check = $"%ThreeCheck"
onready var four_check = $"%FourCheck"

# Do we update the global profile to reflect our values whenever a value gets
# updated?
var _update_global = true

func _ready():
    # Connect to the key update signal, so we can respond to key changes.
    mcc.connect("key_update", self, "_on_mcc_key_update")

func _on_mcc_key_update(key):
    # Disable updating the globabl dictionary - we don't want to update
    # something while we're reading from it!
    _update_global = false
    
    match key:
        #
        # Building
        #
        "lights_one_color":
            one_picker.color = mcc.profile_dict[key]
        "lights_two_color":
            two_picker.color = mcc.profile_dict[key]
        "lights_three_color":
            three_picker.color = mcc.profile_dict[key]
        "lights_four_color":
            four_picker.color = mcc.profile_dict[key]
            
        "lights_one_visible":
            one_check.pressed = mcc.profile_dict[key]
        "lights_two_visible":
            two_check.pressed = mcc.profile_dict[key]
        "lights_three_visible":
            three_check.pressed = mcc.profile_dict[key]
        "lights_four_visible":
            four_check.pressed = mcc.profile_dict[key]

    # Re-enable updating the global dictionary.
    _update_global = true

func _on_OnePicker_color_changed(color):
    if _update_global:
        mcc.profile_dict["lights_one_color"] = color
        mcc.update_key("lights_one_color")

func _on_TwoPicker_color_changed(color):
    if _update_global:
        mcc.profile_dict["lights_two_color"] = color
        mcc.update_key("lights_two_color")

func _on_ThreePicker_color_changed(color):
    if _update_global:
        mcc.profile_dict["lights_three_color"] = color
        mcc.update_key("lights_three_color")

func _on_FourPicker_color_changed(color):
    if _update_global:
        mcc.profile_dict["lights_four_color"] = color
        mcc.update_key("lights_four_color")


func _on_OneCheck_toggled(button_pressed):
    if _update_global:
        mcc.profile_dict["lights_one_visible"] = button_pressed
        mcc.update_key("lights_one_visible")

func _on_TwoCheck_toggled(button_pressed):
    if _update_global:
        mcc.profile_dict["lights_two_visible"] = button_pressed
        mcc.update_key("lights_two_visible")

func _on_ThreeCheck_toggled(button_pressed):
    if _update_global:
        mcc.profile_dict["lights_three_visible"] = button_pressed
        mcc.update_key("lights_three_visible")

func _on_FourCheck_toggled(button_pressed):
    if _update_global:
        mcc.profile_dict["lights_four_visible"] = button_pressed
        mcc.update_key("lights_four_visible")
