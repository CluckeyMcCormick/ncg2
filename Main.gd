extends Spatial

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# TODO: Add lights tab
# TODO: Add second and third building materials
# TODO: Sort out the value_update function's repeat calls
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
    $GUI/Tabs/Stars.update_from_global()
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

func _on_Profiles_profile_change():
    profile_reload()

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
    print( mcc.profile_dict["moon_visible"] )
    $UpCamera/CameraAlignedEffects/Moon.visible = mcc.profile_dict["moon_visible"]
    $UpCamera/CameraAlignedEffects/Moon.translation.x = mcc.profile_dict["moon_x_pos"]
    $UpCamera/CameraAlignedEffects/Moon.translation.y = mcc.profile_dict["moon_y_pos"]
    $UpCamera/CameraAlignedEffects/Moon.mesh.radius = mcc.profile_dict["moon_size"]
    $UpCamera/CameraAlignedEffects/Moon.mesh.height = mcc.profile_dict["moon_size"] * 2



