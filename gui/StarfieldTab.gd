extends Tabs

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# Emitted when the user presses the "regenerate" button
signal regenerate()

# Emitted when the user changes a value. Emitted AFTER the mcc profile value has
# been changed
signal value_update()

onready var height = $HBox/SpinGrid/HeightSpinBox
onready var type_a = $HBox/SpinGrid/TypeASpinBox
onready var type_b = $HBox/SpinGrid/TypeBSpinBox
onready var type_c = $HBox/SpinGrid/TypeCSpinBox
onready var mean = $HBox/SpinGrid/MeanSpinBox
onready var variance = $HBox/SpinGrid/VarianceSpinBox

# Do we update the global profile to reflect our values whenever a value gets
# updated?
var _update_global = true

# Updates the GUI to match what's in the global dictionary
func update_from_global():
    # Disable updating the globabl dictionary - we don't want to update
    # something while we're reading from it!
    _update_global = false
    
    height.value = mcc.profile_dict["starfield_height"]
    type_a.value = mcc.profile_dict["starfield_type_a_count"]
    type_b.value = mcc.profile_dict["starfield_type_b_count"]
    type_c.value = mcc.profile_dict["starfield_type_c_count"]
    mean.value = mcc.profile_dict["starfield_scale_mean"]
    variance.value = mcc.profile_dict["starfield_scale_variance"]
    
    # Re-enable updating the global dictionary.
    _update_global = true

func _on_HeightSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["starfield_height"] = value
    
    mcc.key_update("starfield_height")
    emit_signal("value_update")

func _on_TypeASpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["starfield_type_a_count"] = value
    
    mcc.key_update("starfield_type_a_count")
    emit_signal("value_update")

func _on_TypeBSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["starfield_type_b_count"] = value
    
    mcc.key_update("starfield_type_b_count")
    emit_signal("value_update")

func _on_TypeCSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["starfield_type_c_count"] = value
    
    mcc.key_update("starfield_type_c_count")
    emit_signal("value_update")

func _on_MeanSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["starfield_scale_mean"] = value
    
    mcc.key_update("starfield_scale_mean")
    emit_signal("value_update")

func _on_VarianceSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["starfield_scale_variance"] = value
    
    mcc.key_update("starfield_scale_variance")
    emit_signal("value_update")

func _on_RegenerateButton_pressed():
    emit_signal("regenerate")
