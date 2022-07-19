extends Tabs

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# Updates the GUI to match what's in the global dictionary
func update_from_global():

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

# Updates the global dictionary to match what's in the gui, then
func update_to_global():

    # Update the relevant dictionary entries
    mcc.profile_dict["sky_sky_top"] = $VBox/SkyGrid/TopPicker.color
    mcc.profile_dict["sky_sky_horizon"] = $VBox/SkyGrid/HorizonPicker.color
    mcc.profile_dict["sky_sky_curve"] = $VBox/SkyGrid/SkyCurveSpin.value
    mcc.profile_dict["sky_ground_horizon"] = $VBox/GroundGrid/HorizonPicker.color
    mcc.profile_dict["sky_ground_bottom"] = $VBox/GroundGrid/BottomPicker.color
    mcc.profile_dict["sky_ground_curve"] = $VBox/GroundGrid/GroundCurveSpin.value
    
    # Assert the dictionary's values, putting the updated values into practice.
    mcc.dictionary_assert()

func _on_TopPicker_color_changed(color):
    $VBox/SkyGrid/TopHash.text = "#" + color.to_html()
    update_to_global()

func _on_SkyHorizonPicker_color_changed(color):
    $VBox/SkyGrid/HorizonHash.text = "#" + color.to_html()
    update_to_global()

func _on_SkyCurveSpin_value_changed(value):
    update_to_global()

func _on_GroundHorizonPicker_color_changed(color):
    $VBox/GroundGrid/HorizonHash.text = "#" + color.to_html()
    update_to_global()

func _on_BottomPicker_color_changed(color):
    $VBox/GroundGrid/BottomHash.text = "#" + color.to_html()
    update_to_global()

func _on_GroundCurveSpin_value_changed(value):
    update_to_global()
