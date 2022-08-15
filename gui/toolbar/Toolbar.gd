extends PanelContainer

# Echo signal of Environment menu's regenerate function
signal regenerate()
# Signals for the different control menu options.
signal toggle_camera_pause()
signal toggle_effect_pause()
signal toggle_gui()

var visibility_cooldown = false

# Wrapper for the Profile Menu's assert function.
func assert_profile():
    $HBox/ProfileMenu.assert_profile()

func _input(event):
    if self.visible:
        return
    
    if event.is_action_pressed("control_camera_pause"):
        emit_signal("toggle_camera_pause")
        
    elif event.is_action_pressed("control_effect_pause"):
        emit_signal("toggle_effect_pause")
        
    elif event.is_action_pressed("control_toggle_gui"):
        if not visibility_cooldown:
            emit_signal("toggle_gui")
            visibility_cooldown = true
            $VisibilityCooldown.start(.01)

func _on_EnvironmentMenu_regenerate():
    emit_signal("regenerate")

func _on_ControlMenu_toggle_camera_pause():
    emit_signal("toggle_camera_pause")

func _on_ControlMenu_toggle_effect_pause():
    emit_signal("toggle_effect_pause")

func _on_ControlMenu_toggle_gui():
    if not visibility_cooldown:
        emit_signal("toggle_gui")
        visibility_cooldown = true
        $VisibilityCooldown.start(.01)

func _on_VisibilityCooldown_timeout():
    visibility_cooldown = false
