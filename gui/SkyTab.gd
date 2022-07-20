extends Tabs

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# Do we update the global profile to reflect our values whenever a value gets
# updated?
var _update_global = true

# Updates the GUI to match what's in the global dictionary
func update_from_global():
    # Disable updating the globabl dictionary - we don't want to update
    # something while we're reading from it!
    _update_global = false
    
    $VBox/SkyGrid/TopPicker.color = mcc.profile_dict["sky_sky_top"]
    $VBox/SkyGrid/HorizonPicker.color = mcc.profile_dict["sky_sky_horizon"]
    $VBox/SkyGrid/SkyCurveSpin.value = mcc.profile_dict["sky_sky_curve"]
    $VBox/GroundGrid/HorizonPicker.color = mcc.profile_dict["sky_ground_horizon"]
    $VBox/GroundGrid/BottomPicker.color = mcc.profile_dict["sky_ground_bottom"]
    $VBox/GroundGrid/GroundCurveSpin.value = mcc.profile_dict["sky_ground_curve"]
    
    # Update our labels
    $VBox/SkyGrid/TopHash.text = "#" + $VBox/SkyGrid/TopPicker.color.to_html()
    $VBox/SkyGrid/HorizonHash.text = "#" + $VBox/SkyGrid/HorizonPicker.color.to_html()
    $VBox/GroundGrid/HorizonHash.text = "#" + $VBox/GroundGrid/HorizonPicker.color.to_html()
    $VBox/GroundGrid/BottomHash.text = "#" + $VBox/GroundGrid/BottomPicker.color.to_html()
    
    # Re-enable updating the global dictionary.
    _update_global = true

func _on_TopPicker_color_changed(color):
    $VBox/SkyGrid/TopHash.text = "#" + color.to_html()
    
    if _update_global:
        mcc.profile_dict["sky_sky_top"] = color
    
    mcc.key_update("sky_sky_top")

func _on_SkyHorizonPicker_color_changed(color):
    $VBox/SkyGrid/HorizonHash.text = "#" + color.to_html()
    
    if _update_global:
        mcc.profile_dict["sky_sky_horizon"] = color
    
    mcc.key_update("sky_sky_horizon")

func _on_SkyCurveSpin_value_changed(value):
    if _update_global:
        mcc.profile_dict["sky_sky_curve"] = value
    
    mcc.key_update("sky_sky_curve")

func _on_GroundHorizonPicker_color_changed(color):
    $VBox/GroundGrid/HorizonHash.text = "#" + color.to_html()

    if _update_global:
        mcc.profile_dict["sky_ground_horizon"] = color
    
    mcc.key_update("sky_ground_horizon")

func _on_BottomPicker_color_changed(color):
    $VBox/GroundGrid/BottomHash.text = "#" + color.to_html()

    if _update_global:
        mcc.profile_dict["sky_ground_bottom"] = color
    
    mcc.key_update("sky_ground_bottom")

func _on_GroundCurveSpin_value_changed(value):
    if _update_global:
        mcc.profile_dict["sky_ground_curve"] = $value
    
    mcc.key_update("sky_ground_curve")
