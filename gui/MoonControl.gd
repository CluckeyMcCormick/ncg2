extends VBoxContainer

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

onready var visible_moon = $"%MoonVisCheckBox"
onready var color_picker = $"%MoonColorPickerButton"
onready var x_pos = $"%MoonXPosSpinBox"
onready var y_pos = $"%MoonYPosSpinBox"
onready var size = $"%MoonSizeSpinBox"

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
        # Moon
        #
        "moon_visible":
            visible_moon.pressed = mcc.profile_dict[key]
        "moon_color":
            color_picker.color = mcc.profile_dict[key]
        "moon_x_pos":
            x_pos.value = mcc.profile_dict[key]
        "moon_y_pos":
            y_pos.value = mcc.profile_dict[key]
        "moon_size":
            size.value = mcc.profile_dict[key]

    # Re-enable updating the global dictionary.
    _update_global = true

func _on_MoonVisCheckBox_toggled(button_pressed):
    if _update_global:
        mcc.profile_dict["moon_visible"] = button_pressed
        mcc.update_key("moon_visible")

func _on_MoonColorPickerButton_color_changed(color):
    if _update_global:
        mcc.profile_dict["moon_color"] = color
        mcc.update_key("moon_color")

func _on_MoonXPosSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["moon_x_pos"] = value
        mcc.update_key("moon_x_pos")

func _on_MoonYPosSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["moon_y_pos"] = value
        mcc.update_key("moon_y_pos")

func _on_MoonSizeSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["moon_size"] = value
        mcc.update_key("moon_size")
