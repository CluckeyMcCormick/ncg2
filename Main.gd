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
    
    $GUI/TabContainer/Material/VBoxContainer/WindowColor.color = mcc.lighten_material.get_shader_param("window_color")
    $GUI/TabContainer/Material/VBoxContainer/DarkColor.color = mcc.lighten_material.get_shader_param("dark_color")

func _input(event):
    if event.is_action_pressed("gui_toggle"):
        $GUI.visible = not $GUI.visible

func _on_ColorPickerButton1_color_changed(color):
    mcc.light_color_one = color

func _on_ColorPickerButton2_color_changed(color):
    mcc.light_color_two = color

func _on_ColorPickerButton3_color_changed(color):
    mcc.light_color_three = color

func _on_WindowColor_color_changed(color):
    mcc.lighten_material.set_shader_param("window_color", color)
    mcc.dodge_material.set_shader_param("window_color", color)
    mcc.dither_material.set_shader_param("window_color", color)

func _on_DarkColor_color_changed(color):
    mcc.lighten_material.set_shader_param("dark_color", color)
    mcc.dodge_material.set_shader_param("dark_color", color)
    mcc.dither_material.set_shader_param("dark_color", color)


func _on_MaterialSelection_item_selected(index):
    match index:
        0:
            mcc.primary_material = mcc.lighten_material
            
        1:
            mcc.primary_material = mcc.dodge_material
        
        2:
            mcc.primary_material = mcc.dither_material
            
        _:
            pass
