extends Spatial

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# TODO: Isolate each individual GUI tab into it's own scene with it's own script
# TODO: Create a top-level script GUI script to manage each of those tabs
# TODO: Load profiles from a JSON file (w/ permanent and user pools)
# TODO: Add ability for user to save profiles

var city_built = false

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    
    $GUI/Tabs/Profiles/VBox/ProfileSelection.select(0)
    _on_ProfileSelection_item_selected(0)

func _input(event):
    if event.is_action_pressed("gui_toggle"):
        $GUI.visible = not $GUI.visible
    elif event.is_action_pressed("game_pause"):
        get_tree().paused = not get_tree().paused

func _physics_process(delta):
    if city_built:
        $UpCamera.global_transform.origin += Vector3(2, 0, 0) * delta

func _on_GrowBlockCity_city_complete():
    city_built = true

func assert_color_profile(arg_dict):
    # We're going to manually set all of these profile values, and call each
    # callback function manually. Kinda sucks, but this whole project is a kind
    # of hacky workaround so whatever.
    
    # Building options
    $GUI/Tabs/Buildings/VBox/GridContainer/BuildingPicker.color =  arg_dict["bld_base_color"]
    _on_BuildingPicker_color_changed(arg_dict["bld_base_color"])
    $GUI/Tabs/Buildings/VBox/GridContainer/RedPicker.color = arg_dict["bld_red_dot"]
    _on_RedPicker_color_changed(arg_dict["bld_red_dot"])
    $GUI/Tabs/Buildings/VBox/GridContainer/GreenPicker.color = arg_dict["bld_green_dot"]
    _on_GreenPicker_color_changed(arg_dict["bld_green_dot"])
    $GUI/Tabs/Buildings/VBox/GridContainer/BluePicker.color = arg_dict["bld_blue_dot"]
    _on_BluePicker_color_changed(arg_dict["bld_blue_dot"])
    # Now, set the material appropriately.
    $GUI/Tabs/Buildings/VBox/TextureSelection.selected = arg_dict["bld_texture_code"]
    _on_TextureSelection_item_selected(arg_dict["bld_texture_code"])
    
    # Sky options
    $GUI/Tabs/Sky/VBox/SkyGrid/TopPicker.color = arg_dict["sky_sky_top"]
    _on_TopPicker_color_changed(arg_dict["sky_sky_top"])
    $GUI/Tabs/Sky/VBox/SkyGrid/HorizonPicker.color = arg_dict["sky_sky_horizon"]
    _on_HorizonSkyPicker_color_changed(arg_dict["sky_sky_horizon"])
    $GUI/Tabs/Sky/VBox/SkyGrid/SkyCurveSpin.value = arg_dict["sky_sky_curve"]
    _on_SkyCurveSpin_value_changed(arg_dict["sky_sky_curve"])
    $GUI/Tabs/Sky/VBox/GroundGrid/HorizonPicker.color = arg_dict["sky_ground_horizon"]
    _on_HorizonGroundPicker_color_changed(arg_dict["sky_ground_horizon"])
    $GUI/Tabs/Sky/VBox/GroundGrid/BottomPicker.color = arg_dict["sky_ground_bottom"]
    _on_BottomPicker_color_changed(arg_dict["sky_ground_bottom"])
    $GUI/Tabs/Sky/VBox/GroundGrid/GroundCurveSpin.value = arg_dict["sky_ground_curve"]
    _on_GroundCurveSpin_value_changed(arg_dict["sky_ground_curve"])
    
    # Starfield Options
    $GUI/Tabs/Starfield/HBox/SpinGrid/HeightSpinBox.value = arg_dict["starfield_height"]
    _on_HeightSpinBox_value_changed(arg_dict["starfield_height"])
    $GUI/Tabs/Starfield/HBox/SpinGrid/TypeASpinBox.value = arg_dict["starfield_type_a_count"]
    _on_TypeASpinBox_value_changed(arg_dict["starfield_type_a_count"])
    $GUI/Tabs/Starfield/HBox/SpinGrid/TypeBSpinBox.value = arg_dict["starfield_type_b_count"]
    _on_TypeBSpinBox_value_changed(arg_dict["starfield_type_b_count"])
    $GUI/Tabs/Starfield/HBox/SpinGrid/TypeCSpinBox.value = arg_dict["starfield_type_c_count"]
    _on_TypeCSpinBox_value_changed(arg_dict["starfield_type_c_count"])
    $GUI/Tabs/Starfield/HBox/SpinGrid/MeanSpinBox.value = arg_dict["starfield_scale_mean"]
    _on_MeanSpinBox_value_changed(arg_dict["starfield_scale_mean"])
    $GUI/Tabs/Starfield/HBox/SpinGrid/VarianceSpinBox.value = arg_dict["starfield_scale_variance"]
    _on_VarianceSpinBox_value_changed(arg_dict["starfield_scale_variance"])
    
    # Stars options
    $GUI/Tabs/Stars/VBox/HBoxTypeA/ColorPickerButton.color = arg_dict["stars_type_a_color"]
    _on_TypeA_ColorPickerButton_color_changed(arg_dict["stars_type_a_color"])
    $GUI/Tabs/Stars/VBox/HBoxTypeA/OptionButton.selected = arg_dict["stars_type_a_texture"]
    _on_TypeA_OptionButton_item_selected(arg_dict["stars_type_a_texture"])
    $GUI/Tabs/Stars/VBox/HBoxTypeB/ColorPickerButton.color = arg_dict["stars_type_b_color"]
    _on_TypeB_ColorPickerButton_color_changed(arg_dict["stars_type_b_color"])
    $GUI/Tabs/Stars/VBox/HBoxTypeB/OptionButton.selected = arg_dict["stars_type_b_texture"]
    _on_TypeB_OptionButton_item_selected(arg_dict["stars_type_b_texture"])
    $GUI/Tabs/Stars/VBox/HBoxTypeC/ColorPickerButton.color = arg_dict["stars_type_c_color"]
    _on_TypeC_ColorPickerButton_color_changed(arg_dict["stars_type_c_color"])
    $GUI/Tabs/Stars/VBox/HBoxTypeC/OptionButton.selected = arg_dict["stars_type_c_texture"]
    _on_TypeC_OptionButton_item_selected(arg_dict["stars_type_c_texture"])
    
    # Moon options
    $GUI/Tabs/Moon/VBox/HBoxContainer/MoonVisCheckBox.pressed = arg_dict["moon_visible"]
    _on_MoonVisCheckBox_toggled(arg_dict["moon_visible"])
    $GUI/Tabs/Moon/VBox/HBoxContainer/MoonColorPickerButton.color = arg_dict["moon_color"]
    _on_MoonColorPickerButton_color_changed(arg_dict["moon_color"])
    $GUI/Tabs/Moon/VBox/HBoxPos/MoonXPosSpinBox.value = arg_dict["moon_x_pos"]
    _on_MoonXPosSpinBox_value_changed(arg_dict["moon_x_pos"])
    $GUI/Tabs/Moon/VBox/HBoxPos/MoonYPosSpinBox.value = arg_dict["moon_y_pos"]
    _on_MoonYPosSpinBox_value_changed(arg_dict["moon_y_pos"])
    $GUI/Tabs/Moon/VBox/HBoxSize/MoonSizeSpinBox.value = arg_dict["moon_size"]
    _on_MoonSizeSpinBox_value_changed(arg_dict["moon_size"])


func _on_ProfileSelection_item_selected(index):
    
    var arg_dict = {
        "bld_base_color": Color("#000d20"),
        "bld_red_dot": Color("#77121a"),
        "bld_green_dot": Color("#98c7d1"),
        "bld_blue_dot": Color("#d1cc64"),
        "bld_texture_code": 2,
        
        "sky_sky_top": Color("#003f96"),
        "sky_sky_horizon": Color("#9f84b7"),
        "sky_sky_curve": 365,
        "sky_ground_horizon": Color("#003f96"),
        "sky_ground_bottom": Color("#070a1b"),
        "sky_ground_curve": 200,
        
        "starfield_height": 15,
        "starfield_type_a_count": 20,
        "starfield_type_b_count": 20,
        "starfield_type_c_count": 20,
        "starfield_scale_mean": 1.7,
        "starfield_scale_variance": .3,
        
        "stars_type_a_color": Color.white,
        "stars_type_a_texture": 0,
        "stars_type_b_color": Color.white,
        "stars_type_b_texture": 0,
        "stars_type_c_color": Color.white,
        "stars_type_c_texture": 0,
        
        "moon_visible": true,
        "moon_color": Color.white,
        "moon_x_pos": -10,
        "moon_y_pos": 5.55,
        "moon_size": 1.25,
    }

    match index:
        0:
            # Default profile IS profile 0, so just pass it straight.
            assert_color_profile(arg_dict)
            
        1:
            arg_dict["bld_base_color"] = Color("#12060b")
            arg_dict["bld_red_dot"] = Color("#ffffcc")
            arg_dict["bld_green_dot"] = Color("#4a3b46")
            arg_dict["bld_blue_dot"] = Color("#260d17")
            arg_dict["bld_texture_code"] = 8
            
            arg_dict["sky_sky_top"] = Color("#003f96")
            arg_dict["sky_sky_horizon"] = Color("#ff0000")
            arg_dict["sky_sky_curve"] = 563
            arg_dict["sky_ground_horizon"] = Color("#ff0000")
            arg_dict["sky_ground_bottom"] = Color("#070a1b")
            arg_dict["sky_ground_curve"] = 200
            
            arg_dict["starfield_height"] = 8
            arg_dict["starfield_type_a_count"] = 6
            arg_dict["starfield_type_b_count"] = 6
            arg_dict["starfield_type_c_count"] = 6
            arg_dict["starfield_scale_mean"] = 0.5
            arg_dict["starfield_scale_variance"] = 0.2
            
            arg_dict["moon_visible"] = false
            
            assert_color_profile(arg_dict)
            
        2:
            arg_dict["bld_base_color"] = Color("#12060b")
            arg_dict["bld_red_dot"] = Color("#e4f0e6")
            arg_dict["bld_green_dot"] = Color("#ffe54c")
            arg_dict["bld_blue_dot"] = Color("#8fd2ef")
            arg_dict["bld_texture_code"] = 1
            
            arg_dict["sky_sky_top"] = Color("#45003c")
            arg_dict["sky_sky_horizon"] = Color("#ff5e6e")
            arg_dict["sky_sky_curve"] = 375
            arg_dict["sky_ground_horizon"] = Color("#af0342")
            arg_dict["sky_ground_bottom"] = Color("#45003c")
            arg_dict["sky_ground_curve"] = 200
            
            arg_dict["starfield_height"] = 6.75
            arg_dict["starfield_type_a_count"] = 4
            arg_dict["starfield_type_b_count"] = 4
            arg_dict["starfield_type_c_count"] = 4
            arg_dict["starfield_scale_mean"] = 1
            arg_dict["starfield_scale_variance"] = 1
            
            arg_dict["moon_visible"] = false
            
            assert_color_profile(arg_dict)
            
        3:
            arg_dict["bld_base_color"] = Color("#0c3659")
            arg_dict["bld_red_dot"] = Color("#ffb3db")
            arg_dict["bld_green_dot"] = Color("#ffff80")
            arg_dict["bld_blue_dot"] = Color("#99fff1")
            arg_dict["bld_texture_code"] = 10
            
            arg_dict["sky_sky_top"] = Color("#005f82")
            arg_dict["sky_sky_horizon"] = Color("#51dbb4")
            arg_dict["sky_sky_curve"] = 380
            arg_dict["sky_ground_horizon"] = Color("#51dbb4")
            arg_dict["sky_ground_bottom"] = Color("#003e54")
            arg_dict["sky_ground_curve"] = 1000
            
            arg_dict["starfield_height"] = 20
            arg_dict["starfield_type_a_count"] = 30
            arg_dict["starfield_type_b_count"] = 30
            arg_dict["starfield_type_c_count"] = 30
            arg_dict["starfield_scale_mean"] = 2
            arg_dict["starfield_scale_variance"] = .75
            
            arg_dict["stars_type_a_color"] = Color("#ffffff")
            arg_dict["stars_type_a_texture"] = 1
            arg_dict["stars_type_b_color"] = Color("#ffffff")
            arg_dict["stars_type_b_texture"] = 1
            arg_dict["stars_type_c_color"] = Color("#ffffff")
            arg_dict["stars_type_c_texture"] = 1
            
            arg_dict["moon_visible"] = true
            arg_dict["moon_x_pos"] = 6.74
            arg_dict["moon_y_pos"] = 5.48
            arg_dict["moon_size"] = 2
            
            assert_color_profile(arg_dict)
        4:
            arg_dict["bld_base_color"] = Color("#00000000")
            arg_dict["bld_red_dot"] = Color("#c53920")
            arg_dict["bld_green_dot"] = Color("#3b95d4")
            arg_dict["bld_blue_dot"] = Color("#f2f011")
            arg_dict["bld_texture_code"] = 11
            
            arg_dict["sky_sky_top"] = Color("#000000")
            arg_dict["sky_sky_horizon"] = Color("#000000")
            arg_dict["sky_sky_curve"] = 380
            arg_dict["sky_ground_horizon"] = Color("#000000")
            arg_dict["sky_ground_bottom"] = Color("#000000")
            arg_dict["sky_ground_curve"] = 1000
            
            arg_dict["starfield_height"] = 25
            arg_dict["starfield_type_a_count"] = 60
            arg_dict["starfield_type_b_count"] = 60
            arg_dict["starfield_type_c_count"] = 60
            arg_dict["starfield_scale_mean"] = 4
            arg_dict["starfield_scale_variance"] = 1
            
            arg_dict["stars_type_a_texture"] = 2
            arg_dict["stars_type_b_texture"] = 3
            arg_dict["stars_type_c_texture"] = 4
            
            arg_dict["moon_visible"] = false
            
            assert_color_profile(arg_dict)
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
        8:
            mcc.primary_material.set_shader_param("DotTexture", mcc.square64_25)
        9:
            mcc.primary_material.set_shader_param("DotTexture", mcc.square64_50)
        10:
            mcc.primary_material.set_shader_param("DotTexture", mcc.square64_75)
        11:
            mcc.primary_material.set_shader_param("DotTexture", mcc.square64_100)
        12:
            mcc.primary_material.set_shader_param("DotTexture", mcc.smorgas64_25)
        13:
            mcc.primary_material.set_shader_param("DotTexture", mcc.smorgas64_50)
        14:
            mcc.primary_material.set_shader_param("DotTexture", mcc.smorgas64_75)
        15:
            mcc.primary_material.set_shader_param("DotTexture", mcc.smorgas64_100)
        16:
            mcc.primary_material.set_shader_param("DotTexture", mcc.everything64)
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

func _on_TypeA_ColorPickerButton_color_changed(color):
    mcc.type_a_material.albedo_color = color

func _on_TypeA_OptionButton_item_selected(index):
    var mat = mcc.type_a_material
    
    match index:
        0:
            # Dot
            mat.albedo_texture = mcc.s64_dot
        1:
            # Star
            mat.albedo_texture = mcc.s64_star
        2:
            # 50's Sparkle A
            mat.albedo_texture = mcc.s64_sparkle_a
        3:
            # 50's Sparkle B
            mat.albedo_texture = mcc.s64_sparkle_b
        4:
            # 50's Sparkle C
            mat.albedo_texture = mcc.s64_sparkle_c
        _:
            pass

func _on_TypeB_ColorPickerButton_color_changed(color):
    mcc.type_b_material.albedo_color = color

func _on_TypeB_OptionButton_item_selected(index):
    var mat = mcc.type_b_material
    
    match index:
        0:
            # Dot
            mat.albedo_texture = mcc.s64_dot
        1:
            # Star
            mat.albedo_texture = mcc.s64_star
        2:
            # 50's Sparkle A
            mat.albedo_texture = mcc.s64_sparkle_a
        3:
            # 50's Sparkle B
            mat.albedo_texture = mcc.s64_sparkle_b
        4:
            # 50's Sparkle C
            mat.albedo_texture = mcc.s64_sparkle_c
        _:
            pass

func _on_TypeC_ColorPickerButton_color_changed(color):
    mcc.type_c_material.albedo_color = color

func _on_TypeC_OptionButton_item_selected(index):
    
    var mat = mcc.type_c_material
    
    match index:
        0:
            # Dot
            mat.albedo_texture = mcc.s64_dot
        1:
            # Star
            mat.albedo_texture = mcc.s64_star
        2:
            # 50's Sparkle A
            mat.albedo_texture = mcc.s64_sparkle_a
        3:
            # 50's Sparkle B
            mat.albedo_texture = mcc.s64_sparkle_b
        4:
            # 50's Sparkle C
            mat.albedo_texture = mcc.s64_sparkle_c
        _:
            pass

func _on_MoonVisCheckBox_toggled(button_pressed):
    $UpCamera/CameraAlignedEffects/Moon.visible = button_pressed

func _on_MoonColorPickerButton_color_changed(color):
    mcc.moon_material.albedo_color = color

func _on_MoonXPosSpinBox_value_changed(value):
    $UpCamera/CameraAlignedEffects/Moon.translation.x = value

func _on_MoonYPosSpinBox_value_changed(value):
    $UpCamera/CameraAlignedEffects/Moon.translation.y = value

func _on_MoonSizeSpinBox_value_changed(value):
    $UpCamera/CameraAlignedEffects/Moon.mesh.radius = value
    $UpCamera/CameraAlignedEffects/Moon.mesh.height = value * 2
