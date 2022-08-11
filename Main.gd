extends Spatial

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# TODO: Dynamically generate building textures via blitting.
# TODO: Add second and third building materials.
# TODO: Revise GUI to a "Toolbar" w/pop-ups
# TODO: Decorations (see FootprintBuilding)
# TODO: Load profiles from a JSON file (w/ permanent and user pools)
# TODO: Add ability for user to save profiles

var city_built = false

# Called when the node enters the scene tree for the first time.
func _ready():
    # Connect to the key update signal, so we can respond to key changes.
    mcc.connect("key_update", self, "_on_mcc_key_update")
    randomize()
    $GUI/Tabs/Profiles.assert_profile()

func _input(event):
    if event.is_action_pressed("gui_toggle"):
        $GUI.visible = not $GUI.visible
    elif event.is_action_pressed("game_pause"):
        get_tree().paused = not get_tree().paused

func _physics_process(delta):
    if city_built:
        $UpCamera.global_transform.origin += Vector3(2, 0, 0) * delta
        $Camera.global_transform.origin += Vector3(2, 0, 0) * delta 
        $RoofSlope.global_transform.origin += Vector3(2, 0, 0) * delta 

func _on_GrowBlockCity_city_complete():
    city_built = true

func _on_mcc_key_update(key):
    match key:
        #
        # Starfield
        #
        "starfield_height":
            $UpCamera/CameraAlignedEffects/Starfield.height = mcc.profile_dict[key]
            _on_Starfield_regenerate()
        "starfield_type_a_count":
            $UpCamera/CameraAlignedEffects/Starfield.field_a_count = mcc.profile_dict[key]
            _on_Starfield_regenerate()
        "starfield_type_b_count":
            $UpCamera/CameraAlignedEffects/Starfield.field_b_count = mcc.profile_dict[key]
            _on_Starfield_regenerate()
        "starfield_type_c_count":
            $UpCamera/CameraAlignedEffects/Starfield.field_c_count = mcc.profile_dict[key]
            _on_Starfield_regenerate()
        "starfield_scale_mean":
            $UpCamera/CameraAlignedEffects/Starfield.scale_mean = mcc.profile_dict[key]
            _on_Starfield_regenerate()
        "starfield_scale_variance":
            $UpCamera/CameraAlignedEffects/Starfield.scale_variance = mcc.profile_dict[key]
            _on_Starfield_regenerate()
        #
        # Moon
        #
        "moon_visible":
            $UpCamera/CameraAlignedEffects/Moon.visible = mcc.profile_dict[key]
        "moon_x_pos":
            $UpCamera/CameraAlignedEffects/Moon.translation.x = mcc.profile_dict[key]
        "moon_y_pos":
            $UpCamera/CameraAlignedEffects/Moon.translation.y = mcc.profile_dict[key]
        "moon_size":
            $UpCamera/CameraAlignedEffects/Moon.mesh.radius = mcc.profile_dict[key]
            $UpCamera/CameraAlignedEffects/Moon.mesh.height = mcc.profile_dict[key] * 2

        #
        # Sparkles
        #
        "sparkle_count_a":
            $UpCamera/CameraAlignedEffects/ParticlesA.amount = mcc.profile_dict[key]
        "sparkle_count_b":
            $UpCamera/CameraAlignedEffects/ParticlesB.amount = mcc.profile_dict[key]
        "sparkle_count_c":
            $UpCamera/CameraAlignedEffects/ParticlesC.amount = mcc.profile_dict[key]
        "sparkle_lifetime_a":
            $UpCamera/CameraAlignedEffects/ParticlesA.lifetime = mcc.profile_dict[key]
        "sparkle_lifetime_b":
            $UpCamera/CameraAlignedEffects/ParticlesB.lifetime = mcc.profile_dict[key]
        "sparkle_lifetime_c":
            $UpCamera/CameraAlignedEffects/ParticlesC.lifetime = mcc.profile_dict[key]
        "sparkle_randomness_a":
            $UpCamera/CameraAlignedEffects/ParticlesA.randomness = mcc.profile_dict[key]
        "sparkle_randomness_b":
            $UpCamera/CameraAlignedEffects/ParticlesB.randomness = mcc.profile_dict[key]
        "sparkle_randomness_c":
            $UpCamera/CameraAlignedEffects/ParticlesC.randomness = mcc.profile_dict[key]
        "sparkle_enabled_a":
            $UpCamera/CameraAlignedEffects/ParticlesA.emitting = mcc.profile_dict[key]
        "sparkle_enabled_b":
            $UpCamera/CameraAlignedEffects/ParticlesB.emitting = mcc.profile_dict[key]
        "sparkle_enabled_c":
            $UpCamera/CameraAlignedEffects/ParticlesC.emitting = mcc.profile_dict[key]

func _on_Starfield_regenerate():
    $UpCamera/CameraAlignedEffects/Starfield.generate_field_a()
    $UpCamera/CameraAlignedEffects/Starfield.generate_field_b()
    $UpCamera/CameraAlignedEffects/Starfield.generate_field_c()
