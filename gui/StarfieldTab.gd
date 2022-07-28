extends HBoxContainer

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# Emitted when the user presses the "regenerate" button
signal regenerate()

onready var height = $SpinGrid/HeightSpinBox
onready var type_a = $SpinGrid/TypeASpinBox
onready var type_b = $SpinGrid/TypeBSpinBox
onready var type_c = $SpinGrid/TypeCSpinBox
onready var mean = $SpinGrid/MeanSpinBox
onready var variance = $SpinGrid/VarianceSpinBox

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
        # Starfield
        #
        "starfield_height":
            height.value = mcc.profile_dict[key]
        "starfield_type_a_count":
            type_a.value = mcc.profile_dict[key]
        "starfield_type_b_count":
            type_b.value = mcc.profile_dict[key]
        "starfield_type_c_count":
            type_c.value = mcc.profile_dict[key]
        "starfield_scale_mean":
            mean.value = mcc.profile_dict[key]
        "starfield_scale_variance":
            variance.value = mcc.profile_dict[key]

    # Re-enable updating the global dictionary.
    _update_global = true

func _on_HeightSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["starfield_height"] = value
        mcc.update_key("starfield_height")

func _on_TypeASpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["starfield_type_a_count"] = value
        mcc.update_key("starfield_type_a_count")

func _on_TypeBSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["starfield_type_b_count"] = value
        mcc.update_key("starfield_type_b_count")

func _on_TypeCSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["starfield_type_c_count"] = value
        mcc.update_key("starfield_type_c_count")

func _on_MeanSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["starfield_scale_mean"] = value
        mcc.update_key("starfield_scale_mean")

func _on_VarianceSpinBox_value_changed(value):
    if _update_global:
        mcc.profile_dict["starfield_scale_variance"] = value
        mcc.update_key("starfield_scale_variance")

func _on_RegenerateButton_pressed():
    emit_signal("regenerate")
