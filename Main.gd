extends Spatial

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

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
    $DebugCity.make()
    
    mcc.profile_dict["lights_one_color"] = Color.red
    mcc.profile_dict["lights_two_color"] = Color.green
    mcc.profile_dict["lights_three_color"] = Color.blue
    mcc.profile_dict["lights_four_color"] = Color.yellow
    
    mcc.update_whole_dictionary()
    
    city_built = true

func _physics_process(delta):
    if city_built and movement_enabled:
        $UpCamera.global_transform.origin += Vector3(2, 0, 0) * delta
        $Camera.global_transform.origin += Vector3(2, 0, 0) * delta 
        $RoofSlope.global_transform.origin += Vector3(2, 0, 0) * delta 

func _input(event):
    if event.is_action_pressed("control_camera_pause"):
        movement_enabled = not movement_enabled
    
    if event.is_action_pressed("control_light_one_toggle"):
        mcc.profile_dict["lights_one_visible"] = not mcc.profile_dict["lights_one_visible"]
        mcc.update_key("lights_one_visible")
    
    if event.is_action_pressed("control_light_two_toggle"):
        mcc.profile_dict["lights_two_visible"] = not mcc.profile_dict["lights_two_visible"]
        mcc.update_key("lights_two_visible")
    
    if event.is_action_pressed("control_light_three_toggle"):
        mcc.profile_dict["lights_three_visible"] = not mcc.profile_dict["lights_three_visible"]
        mcc.update_key("lights_three_visible")
    
    if event.is_action_pressed("control_light_four_toggle"):
        mcc.profile_dict["lights_four_visible"] = not mcc.profile_dict["lights_four_visible"]
        mcc.update_key("lights_four_visible")

func _on_Timer_timeout():
    print("Lights: %d Visible: %d" % [mcc.overall_lights, mcc.visible_lights])
