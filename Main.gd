extends Spatial

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# Has the city been built yet?
var city_built = false
# Is the camera moving/panning?
var movement_enabled = true
# Are the effects - i.e. the particles - currently paused?
var effects_paused = false
# Are we allowed to show/hide the GUI? We need this because pressing the "Hide"
# action triggers twice, and I haven't quite been able to solve the why of that.
var gui_flip_enabled = true

# Called when the node enters the scene tree for the first time.
func _ready():
    # Connect to the key update signal, so we can respond to key changes.
    mcc.connect("key_update", self, "_on_mcc_key_update")
    randomize()
    
    $Toolbar.assert_profile()

func _physics_process(delta):
    if city_built and movement_enabled:
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
            $"%Starfield".height = mcc.profile_dict[key]
            _on_Toolbar_regenerate()
        "starfield_type_a_count":
            $"%Starfield".field_a_count = mcc.profile_dict[key]
            _on_Toolbar_regenerate()
        "starfield_type_b_count":
            $"%Starfield".field_b_count = mcc.profile_dict[key]
            _on_Toolbar_regenerate()
        "starfield_type_c_count":
            $"%Starfield".field_c_count = mcc.profile_dict[key]
            _on_Toolbar_regenerate()
        "starfield_scale_mean":
            $"%Starfield".scale_mean = mcc.profile_dict[key]
            _on_Toolbar_regenerate()
        "starfield_scale_variance":
            $"%Starfield".scale_variance = mcc.profile_dict[key]
            _on_Toolbar_regenerate()
        #
        # Moon
        #
        "moon_x_pos":
            $"%Moon".translation.x = mcc.profile_dict[key]
        "moon_y_pos":
            $"%Moon".translation.y = mcc.profile_dict[key]

        #
        # Sparkles
        #
        "sparkle_count_a":
            $"%ParticlesA".amount = mcc.profile_dict[key]
        "sparkle_count_b":
            $"%ParticlesB".amount = mcc.profile_dict[key]
        "sparkle_count_c":
            $"%ParticlesC".amount = mcc.profile_dict[key]
        "sparkle_lifetime_a":
            $"%ParticlesA".lifetime = mcc.profile_dict[key]
        "sparkle_lifetime_b":
            $"%ParticlesB".lifetime = mcc.profile_dict[key]
        "sparkle_lifetime_c":
            $"%ParticlesC".lifetime = mcc.profile_dict[key]
        "sparkle_randomness_a":
            $"%ParticlesA".randomness = mcc.profile_dict[key]
        "sparkle_randomness_b":
            $"%ParticlesB".randomness = mcc.profile_dict[key]
        "sparkle_randomness_c":
            $"%ParticlesC".randomness = mcc.profile_dict[key]
        "sparkle_enabled_a":
            $"%ParticlesA".emitting = mcc.profile_dict[key]
        "sparkle_enabled_b":
            $"%ParticlesB".emitting = mcc.profile_dict[key]
        "sparkle_enabled_c":
            $"%ParticlesC".emitting = mcc.profile_dict[key]

func _on_Toolbar_regenerate():
    $"%Starfield".generate_field_a()
    $"%Starfield".generate_field_b()
    $"%Starfield".generate_field_c()

func _on_Toolbar_toggle_camera_pause():
    movement_enabled = not movement_enabled

func _on_Toolbar_toggle_effect_pause():
    
    effects_paused = not effects_paused
    
    if effects_paused:
        $"%ParticlesA".speed_scale = 0
        $"%ParticlesB".speed_scale = 0
        $"%ParticlesC".speed_scale = 0
    else:
        $"%ParticlesA".speed_scale = 1
        $"%ParticlesB".speed_scale = 1
        $"%ParticlesC".speed_scale = 1

func _on_Toolbar_toggle_gui():
    # Flip the visibility
    $Toolbar.visible = not $Toolbar.visible
