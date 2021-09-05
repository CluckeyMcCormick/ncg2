extends Spatial

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    
    $GUI/Tabs/Profiles/VBox/ProfileSelection.selected = 0
    _on_ProfileSelection_item_selected(0)

func _input(event):
    if event.is_action_pressed("gui_toggle"):
        $GUI.visible = not $GUI.visible

func assert_color_profile(
    building_color, red_dot, green_dot, blue_dot, material_code,
    sky_top, sky_horizon, sky_curve,
    ground_horizon, ground_bottom, ground_curve
):
    # We're going to manually set all of these profile values, and call each
    # callback function manually. Kinda sucks, but this whole project is a kind
    # of hacky workaround so whatever.
    
    # First, set the colors.
    $GUI/Tabs/Windows/VBox/GridContainer/BuildingPicker.color =  building_color
    _on_BuildingPicker_color_changed(building_color)
    $GUI/Tabs/Windows/VBox/GridContainer/RedPicker.color = red_dot
    _on_RedPicker_color_changed(red_dot)
    $GUI/Tabs/Windows/VBox/GridContainer/GreenPicker.color = green_dot
    _on_GreenPicker_color_changed(green_dot)
    $GUI/Tabs/Windows/VBox/GridContainer/BluePicker.color = blue_dot
    _on_BluePicker_color_changed(blue_dot)
    
    # Now, set the material appropriately.
    $GUI/Tabs/Windows/VBox/MaterialSelection.selected = material_code
    _on_MaterialSelection_item_selected(material_code)
    
    # Next, the sky colors
    $GUI/Tabs/Sky/VBox/SkyGrid/TopPicker.color = sky_top
    _on_TopPicker_color_changed(sky_top)
    $GUI/Tabs/Sky/VBox/SkyGrid/HorizonPicker.color = sky_horizon
    _on_HorizonSkyPicker_color_changed(sky_horizon)
    $GUI/Tabs/Sky/VBox/SkyGrid/SkyCurveSpin.value = sky_curve
    _on_SkyCurveSpin_value_changed(sky_curve)

    # Finally, the ground colors
    $GUI/Tabs/Sky/VBox/GroundGrid/HorizonPicker.color = ground_horizon
    _on_HorizonGroundPicker_color_changed(ground_horizon)
    $GUI/Tabs/Sky/VBox/GroundGrid/BottomPicker.color = ground_bottom
    _on_BottomPicker_color_changed(ground_bottom)
    $GUI/Tabs/Sky/VBox/GroundGrid/GroundCurveSpin.value = ground_curve
    _on_GroundCurveSpin_value_changed(ground_curve)


func _on_RedPicker_color_changed(color):
    mcc.primary_material.set_shader_param("RedDotColor", color)
    $GUI/Tabs/Windows/VBox/GridContainer/RedHash.text = "#" + color.to_html()

func _on_GreenPicker_color_changed(color):
    mcc.primary_material.set_shader_param("GreenDotColor", color)
    $GUI/Tabs/Windows/VBox/GridContainer/GreenHash.text = "#" + color.to_html()

func _on_BluePicker_color_changed(color):
    mcc.primary_material.set_shader_param("BlueDotColor", color)
    $GUI/Tabs/Windows/VBox/GridContainer/BlueHash.text = "#" + color.to_html()

func _on_BuildingPicker_color_changed(color):
    mcc.primary_material.set_shader_param("BuildingColor", color)
    $GUI/Tabs/Windows/VBox/GridContainer/BuildingHash.text = "#" + color.to_html()

func _on_MaterialSelection_item_selected(index):
    match index:
        0:
            pass
        1:
            pass
        2:
            print("Material Horizontal 75!")
        3:
            pass
        4:
            pass
        5:
            pass
        6:
            pass
        7:
            pass
        _:
            pass

func _on_TopPicker_color_changed(color):
    $WorldEnvironment.environment.background_sky.sky_top_color = color
    $GUI/Tabs/Sky/VBox/SkyGrid/TopHash.text = "#" + color.to_html()

func _on_HorizonSkyPicker_color_changed(color):
    $WorldEnvironment.environment.background_sky.sky_horizon_color = color
    $GUI/Tabs/Sky/VBox/SkyGrid/HorizonHash.text = "#" + color.to_html()

func _on_SkyCurveSpin_value_changed(value):
    $WorldEnvironment.environment.background_sky.sky_curve = value / 10000.0

func _on_HorizonGroundPicker_color_changed(color):
    $WorldEnvironment.environment.background_sky.ground_horizon_color = color
    $GUI/Tabs/Sky/VBox/GroundGrid/HorizonHash.text = "#" + color.to_html()

func _on_BottomPicker_color_changed(color):
    $WorldEnvironment.environment.background_sky.ground_bottom_color = color
    $GUI/Tabs/Sky/VBox/GroundGrid/BottomHash.text = "#" + color.to_html()

func _on_GroundCurveSpin_value_changed(value):
    $WorldEnvironment.environment.background_sky.ground_curve = value / 10000.0

func _on_ProfileSelection_item_selected(index):
    print("Profile item selected: ", index)
    match index:
        0:
            assert_color_profile(
                Color("#000d20"), # Building Color
                Color("#77121a"), # Red Dot Color
                Color("#98c7d1"), # Green Dot Color
                Color("#d1cc64"), # Blue Dot Color
                2,          # Material Code
                
                Color("#003f96"), # Sky Top Color
                Color("#9f84b7"), # Sky Horizon Color
                365, # Sky Curve Factor
                
                Color("#003f96"), # Ground Horizon Color
                Color("#070a1b"), # Ground Bottom Color
                200 # Ground Curve Factor
            )    
        _:
            pass
