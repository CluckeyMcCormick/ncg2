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
    elif event.is_action_pressed("game_pause"):
        get_tree().paused = not get_tree().paused

func assert_color_profile(
    building_color, red_dot, green_dot, blue_dot, texture_code,
    sky_top, sky_horizon, sky_curve,
    ground_horizon, ground_bottom, ground_curve,
    field_height, stars_type_a_count, stars_type_b_count, stars_type_c_count, 
    star_scale_mean, star_scale_variance
):
    # We're going to manually set all of these profile values, and call each
    # callback function manually. Kinda sucks, but this whole project is a kind
    # of hacky workaround so whatever.
    
    # First, set the colors.
    $GUI/Tabs/Buildings/VBox/GridContainer/BuildingPicker.color =  building_color
    _on_BuildingPicker_color_changed(building_color)
    $GUI/Tabs/Buildings/VBox/GridContainer/RedPicker.color = red_dot
    _on_RedPicker_color_changed(red_dot)
    $GUI/Tabs/Buildings/VBox/GridContainer/GreenPicker.color = green_dot
    _on_GreenPicker_color_changed(green_dot)
    $GUI/Tabs/Buildings/VBox/GridContainer/BluePicker.color = blue_dot
    _on_BluePicker_color_changed(blue_dot)
    
    # Now, set the material appropriately.
    $GUI/Tabs/Buildings/VBox/TextureSelection.selected = texture_code
    _on_TextureSelection_item_selected(texture_code)
    
    # Next, the sky colors
    $GUI/Tabs/Sky/VBox/SkyGrid/TopPicker.color = sky_top
    _on_TopPicker_color_changed(sky_top)
    $GUI/Tabs/Sky/VBox/SkyGrid/HorizonPicker.color = sky_horizon
    _on_HorizonSkyPicker_color_changed(sky_horizon)
    $GUI/Tabs/Sky/VBox/SkyGrid/SkyCurveSpin.value = sky_curve
    _on_SkyCurveSpin_value_changed(sky_curve)

    # The ground colors
    $GUI/Tabs/Sky/VBox/GroundGrid/HorizonPicker.color = ground_horizon
    _on_HorizonGroundPicker_color_changed(ground_horizon)
    $GUI/Tabs/Sky/VBox/GroundGrid/BottomPicker.color = ground_bottom
    _on_BottomPicker_color_changed(ground_bottom)
    $GUI/Tabs/Sky/VBox/GroundGrid/GroundCurveSpin.value = ground_curve
    _on_GroundCurveSpin_value_changed(ground_curve)
    
    # Starfield Options
    $GUI/Tabs/Starfield/HBox/SpinGrid/HeightSpinBox.value = field_height
    _on_HeightSpinBox_value_changed(field_height)
    $GUI/Tabs/Starfield/HBox/SpinGrid/TypeASpinBox.value = stars_type_a_count
    _on_TypeASpinBox_value_changed(stars_type_a_count)
    $GUI/Tabs/Starfield/HBox/SpinGrid/TypeBSpinBox.value = stars_type_b_count
    _on_TypeBSpinBox_value_changed(stars_type_b_count)
    $GUI/Tabs/Starfield/HBox/SpinGrid/TypeCSpinBox.value = stars_type_c_count
    _on_TypeCSpinBox_value_changed(stars_type_c_count)
    $GUI/Tabs/Starfield/HBox/SpinGrid/MeanSpinBox.value = star_scale_mean
    _on_MeanSpinBox_value_changed(star_scale_mean)
    $GUI/Tabs/Starfield/HBox/SpinGrid/VarianceSpinBox.value = star_scale_variance
    _on_VarianceSpinBox_value_changed(star_scale_variance)

func _on_ProfileSelection_item_selected(index):
    print("Profile item selected: ", index)
    match index:
        0:
            assert_color_profile(
                Color("#000d20"), # Building Color
                Color("#77121a"), # Red Dot Color
                Color("#98c7d1"), # Green Dot Color
                Color("#d1cc64"), # Blue Dot Color
                2,          # Texture Code
                
                Color("#003f96"), # Sky Top Color
                Color("#9f84b7"), # Sky Horizon Color
                365, # Sky Curve Factor
                
                Color("#003f96"), # Ground Horizon Color
                Color("#070a1b"), # Ground Bottom Color
                200, # Ground Curve Factor
                
                10, # Star Field Height
                3, # Stars Type A count
                3, # Stars Type B count
                3, # Stars Type C count
                .85, # Star Scale, Mean
                .15 # Star Scale, Variance
            )
        1:
            assert_color_profile(
                Color("#12060b"), # Building Color
                Color("#ffffcc"), # Red Dot Color
                Color("#4a3b46"), # Green Dot Color
                Color("#260d17"), # Blue Dot Color
                0,          # Texture Code
                
                Color("#003f96"), # Sky Top Color
                Color("#ff0000"), # Sky Horizon Color
                563, # Sky Curve Factor
                
                Color("#ff0000"), # Ground Horizon Color
                Color("#070a1b"), # Ground Bottom Color
                200, # Ground Curve Factor
                
                0, # Star Field Height
                0, # Stars Type A count
                0, # Stars Type B count
                0, # Stars Type C count
                0, # Star Scale, Mean
                0 # Star Scale, Variance
            )
        2:
            assert_color_profile(
                Color("#12060b"), # Building Color
                Color("#e4f0e6"), # Red Dot Color
                Color("#ffe54c"), # Green Dot Color
                Color("#8fd2ef"), # Blue Dot Color
                1,          # Texture Code
                
                Color("#9e1875"), # Sky Top Color
                Color("#d15e7d"), # Sky Horizon Color
                500, # Sky Curve Factor
                
                Color("#1d1f50"), # Ground Horizon Color
                Color("#070a1b"), # Ground Bottom Color
                200, # Ground Curve Factor
                
                12, # Star Field Height
                20, # Stars Type A count
                20, # Stars Type B count
                20, # Stars Type C count
                .85, # Star Scale, Mean
                .15 # Star Scale, Variance
            )
        3:
            assert_color_profile(
                Color("#0c3659"), # Building Color
                Color("#c596ae"), # Red Dot Color
                Color("#9cb389"), # Green Dot Color
                Color("#b1c7c3"), # Blue Dot Color
                3,          # Texture Code
                
                Color("#005f82"), # Sky Top Color
                Color("#51dbb4"), # Sky Horizon Color
                380, # Sky Curve Factor
                
                Color("#51dbb4"), # Ground Horizon Color
                Color("#003e54"), # Ground Bottom Color
                1000, # Ground Curve Factor

                12, # Star Field Height
                20, # Stars Type A count
                20, # Stars Type B count
                20, # Stars Type C count
                .85, # Star Scale, Mean
                .15 # Star Scale, Variance
            )
        _:
            pass

func _on_TextureSelection_item_selected(index):
    match index:
        0:
            mcc.primary_material.set_shader_param("DotTexture", mcc.horiz64_25)
        1:
            mcc.primary_material.set_shader_param("DotTexture", mcc.horiz64_50)
        2:
            mcc.primary_material.set_shader_param("DotTexture", mcc.horiz64_75)
        3:
            mcc.primary_material.set_shader_param("DotTexture", mcc.horiz64_100)
        4:
            mcc.primary_material.set_shader_param("DotTexture", mcc.verti64_25)
        5:
            mcc.primary_material.set_shader_param("DotTexture", mcc.verti64_50)
        6:
            mcc.primary_material.set_shader_param("DotTexture", mcc.verti64_75)
        7:
            mcc.primary_material.set_shader_param("DotTexture", mcc.verti64_100)
        _:
            pass

func _on_RegenerateButton_pressed():
    $UpCamera/CameraAlignedEffects/Starfield.generate_field_a()
    $UpCamera/CameraAlignedEffects/Starfield.generate_field_b()
    $UpCamera/CameraAlignedEffects/Starfield.generate_field_c()

func _on_RedPicker_color_changed(color):
    mcc.primary_material.set_shader_param("RedDotColor", color)
    $GUI/Tabs/Buildings/VBox/GridContainer/RedHash.text = "#" + color.to_html()

func _on_GreenPicker_color_changed(color):
    mcc.primary_material.set_shader_param("GreenDotColor", color)
    $GUI/Tabs/Buildings/VBox/GridContainer/GreenHash.text = "#" + color.to_html()

func _on_BluePicker_color_changed(color):
    mcc.primary_material.set_shader_param("BlueDotColor", color)
    $GUI/Tabs/Buildings/VBox/GridContainer/BlueHash.text = "#" + color.to_html()

func _on_BuildingPicker_color_changed(color):
    mcc.primary_material.set_shader_param("BuildingColor", color)
    $GUI/Tabs/Buildings/VBox/GridContainer/BuildingHash.text = "#" + color.to_html()

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

func _on_BottomSlider_value_changed(value):
    $UpCamera/CameraAlignedEffects/Starfield.height = value

func _on_HeightSpinBox_value_changed(value):
    $UpCamera/CameraAlignedEffects/Starfield.height = value

func _on_TypeASpinBox_value_changed(value):
    $UpCamera/CameraAlignedEffects/Starfield.field_a_count = value

func _on_TypeBSpinBox_value_changed(value):
    $UpCamera/CameraAlignedEffects/Starfield.field_b_count = value

func _on_TypeCSpinBox_value_changed(value):
    $UpCamera/CameraAlignedEffects/Starfield.field_c_count = value

func _on_MeanSpinBox_value_changed(value):
    $UpCamera/CameraAlignedEffects/Starfield.scale_mean = value

func _on_VarianceSpinBox_value_changed(value):
    $UpCamera/CameraAlignedEffects/Starfield.scale_variance = value
