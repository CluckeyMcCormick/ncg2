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
    profile_reload()

func profile_reload():
    $GUI/Tabs/Buildings.update_from_global()
    $GUI/Tabs/Sky.update_from_global()
    $GUI/Tabs/Starfield.update_from_global()
    $GUI/Tabs/Moon.update_from_global()

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
            pass
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
        _:
            pass

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

func _on_Starfield_regenerate():
    $UpCamera/CameraAlignedEffects/Starfield.generate_field_a()
    $UpCamera/CameraAlignedEffects/Starfield.generate_field_b()
    $UpCamera/CameraAlignedEffects/Starfield.generate_field_c()

func _on_Starfield_value_update():
    $UpCamera/CameraAlignedEffects/Starfield.height = mcc.profile_dict["starfield_height"]
    $UpCamera/CameraAlignedEffects/Starfield.field_a_count = mcc.profile_dict["starfield_type_a_count"]
    $UpCamera/CameraAlignedEffects/Starfield.field_b_count = mcc.profile_dict["starfield_type_b_count"]
    $UpCamera/CameraAlignedEffects/Starfield.field_c_count = mcc.profile_dict["starfield_type_c_count"]
    $UpCamera/CameraAlignedEffects/Starfield.scale_mean = mcc.profile_dict["starfield_scale_mean"]
    $UpCamera/CameraAlignedEffects/Starfield.scale_variance = mcc.profile_dict["starfield_scale_variance"]
    
    _on_Starfield_regenerate()

func _on_Moon_value_update():
    $UpCamera/CameraAlignedEffects/Moon.visible = mcc.profile_dict["moon_visible"]
    $UpCamera/CameraAlignedEffects/Moon.translation.x = mcc.profile_dict["moon_x_pos"]
    $UpCamera/CameraAlignedEffects/Moon.translation.y = mcc.profile_dict["moon_y_pos"]
    $UpCamera/CameraAlignedEffects/Moon.mesh.radius = mcc.profile_dict["moon_size"]
    $UpCamera/CameraAlignedEffects/Moon.mesh.height = mcc.profile_dict["moon_size"] * 2
