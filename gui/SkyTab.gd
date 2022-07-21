extends Tabs

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

onready var sky_top = $VBox/SkyGrid/TopPicker
onready var sky_horizon = $VBox/SkyGrid/HorizonPicker
onready var sky_curve = $VBox/SkyGrid/SkyCurveSpin

onready var ground_horizon = $VBox/GroundGrid/HorizonPicker
onready var ground_bottom = $VBox/GroundGrid/BottomPicker
onready var ground_curve = $VBox/GroundGrid/GroundCurveSpin

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

    # Re-enable updating the global dictionary.
    _update_global = true

func _on_TopPicker_color_changed(color):
    $VBox/SkyGrid/TopHash.text = "#" + color.to_html()
    
    if _update_global:
        mcc.profile_dict["sky_sky_top"] = color
        mcc.update_key("sky_sky_top")

func _on_SkyHorizonPicker_color_changed(color):
    $VBox/SkyGrid/HorizonHash.text = "#" + color.to_html()
    
    if _update_global:
        mcc.profile_dict["sky_sky_horizon"] = color
        mcc.update_key("sky_sky_horizon")

func _on_SkyCurveSpin_value_changed(value):
    if _update_global:
        mcc.profile_dict["sky_sky_curve"] = value
        mcc.update_key("sky_sky_curve")

func _on_GroundHorizonPicker_color_changed(color):
    $VBox/GroundGrid/HorizonHash.text = "#" + color.to_html()

    if _update_global:
        mcc.profile_dict["sky_ground_horizon"] = color
        mcc.update_key("sky_ground_horizon")

func _on_BottomPicker_color_changed(color):
    $VBox/GroundGrid/BottomHash.text = "#" + color.to_html()

    if _update_global:
        mcc.profile_dict["sky_ground_bottom"] = color
        mcc.update_key("sky_ground_bottom")

func _on_GroundCurveSpin_value_changed(value):
    if _update_global:
        mcc.profile_dict["sky_ground_curve"] = $value
        mcc.update_key("sky_ground_curve")
