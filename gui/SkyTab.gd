extends VBoxContainer

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

onready var sky_top = $"%TopPicker"
onready var sky_horizon = $"%SkyHorizonPicker"
onready var sky_curve = $"%SkyCurveSpin"

onready var ground_horizon = $"%GroundHorizonPicker"
onready var ground_bottom = $"%BottomPicker"
onready var ground_curve = $"%GroundCurveSpin"

onready var sky_rotation = $"%RotationSpin"

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
        # Sky
        #
        "sky_sky_top":
            sky_top.color = mcc.profile_dict[key]
        "sky_sky_horizon":
            sky_horizon.color = mcc.profile_dict[key]
        "sky_sky_curve":
            sky_curve.value = mcc.profile_dict[key]
        "sky_ground_horizon":
            ground_horizon.color = mcc.profile_dict[key]
        "sky_ground_bottom":
            ground_bottom.color = mcc.profile_dict[key]
        "sky_ground_curve":
            ground_curve.value = mcc.profile_dict[key]
        "sky_x_rotation":
            sky_rotation.value = mcc.profile_dict[key]

    # Re-enable updating the global dictionary.
    _update_global = true

func _on_TopPicker_color_changed(color):
    if _update_global:
        mcc.profile_dict["sky_sky_top"] = color
        mcc.update_key("sky_sky_top")

func _on_SkyHorizonPicker_color_changed(color):
    if _update_global:
        mcc.profile_dict["sky_sky_horizon"] = color
        mcc.update_key("sky_sky_horizon")

func _on_SkyCurveSpin_value_changed(value):
    if _update_global:
        mcc.profile_dict["sky_sky_curve"] = value
        mcc.update_key("sky_sky_curve")

func _on_GroundHorizonPicker_color_changed(color):
    if _update_global:
        mcc.profile_dict["sky_ground_horizon"] = color
        mcc.update_key("sky_ground_horizon")

func _on_BottomPicker_color_changed(color):
    if _update_global:
        mcc.profile_dict["sky_ground_bottom"] = color
        mcc.update_key("sky_ground_bottom")

func _on_GroundCurveSpin_value_changed(value):
    if _update_global:
        mcc.profile_dict["sky_ground_curve"] = value
        mcc.update_key("sky_ground_curve")

func _on_RotationSpin_value_changed(value):
    if _update_global:
        mcc.profile_dict["sky_x_rotation"] = value
        mcc.update_key("sky_x_rotation")
