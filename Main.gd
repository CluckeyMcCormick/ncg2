extends Spatial

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    
    $GUI/TabContainer/Lights/VBoxContainer/ColorPickerButton1.color = mcc.light_color_one
    $GUI/TabContainer/Lights/VBoxContainer/ColorPickerButton2.color = mcc.light_color_two
    $GUI/TabContainer/Lights/VBoxContainer/ColorPickerButton3.color = mcc.light_color_three

func _input(event):
    if event.is_action_pressed("gui_toggle"):
        $GUI.visible = not $GUI.visible

func _on_ColorPickerButton1_color_changed(color):
    mcc.light_color_one = color

func _on_ColorPickerButton2_color_changed(color):
    mcc.light_color_two = color

func _on_ColorPickerButton3_color_changed(color):
    mcc.light_color_three = color
