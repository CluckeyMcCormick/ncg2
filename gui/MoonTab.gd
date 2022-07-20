extends Tabs

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

onready var visible_moon = $VBox/HBoxContainer/MoonVisCheckBox
onready var color_picker = $VBox/HBoxContainer/MoonColorPickerButton
onready var x_pos = $VBox/HBoxPos/MoonXPosSpinBox
onready var y_pos = $VBox/HBoxPos/MoonYPosSpinBox
onready var size = $VBox/HBoxSize/MoonSizeSpinBox

# Emitted when the user changes a value. Emitted AFTER the mcc profile value has
# been changed
signal value_update()

# Do we update the global profile to reflect our values whenever a value gets
# updated?
var _update_global = true  

# Updates the GUI to match what's in the global dictionary
func update_from_global():
    # Disable updating the globabl dictionary - we don't want to update
    # something while we're reading from it!
    _update_global = false
    
    visible_moon.pressed = mcc.profile_dict["moon_visible"]
    color_picker.color = mcc.profile_dict["moon_color"]
    x_pos.value = mcc.profile_dict["moon_x_pos"]
    y_pos.value = mcc.profile_dict["moon_y_pos"]
    size.value = mcc.profile_dict["moon_size"]
    
    # Re-enable updating the global dictionary.
    _update_global = true

func _on_MoonVisCheckBox_pressed():
    if _update_global:
        mcc.profile_dict["moon_visible"] = visible_moon.pressed
    
    mcc.key_update("moon_visible")
    emit_signal("value_update")

func _on_MoonColorPickerButton_color_changed(color):
    if _update_global:
        mcc.profile_dict["moon_color"] = color
    
    mcc.key_update("moon_color")
    emit_signal("value_update")

func _on_MoonXPosSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["moon_x_pos"] = value
    
    mcc.key_update("moon_x_pos")
    emit_signal("value_update")

func _on_MoonYPosSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["moon_y_pos"] = value
    
    mcc.key_update("moon_y_pos")
    emit_signal("value_update")

func _on_MoonSizeSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["moon_size"] = value
    
    mcc.key_update("moon_size")
    emit_signal("value_update")
