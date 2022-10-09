extends PanelContainer

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# Echo signal of Environment menu's regenerate function
signal regenerate()
# Signals for the different control menu options.
signal toggle_camera_pause()
signal toggle_effect_pause()
signal toggle_gui()

var visibility_cooldown = false

func _ready():
    # Connect to the key update signal, so we can respond to key changes.
    mcc.connect("key_update", self, "_on_mcc_key_update")

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

func _on_Credits_pressed():
    $HBox/Credits/CreditsDialog.popup_centered_minsize()

func _on_VisibilityCooldown_timeout():
    visibility_cooldown = false

func _on_mcc_key_update(key):
    var notes_string = ""
    var sep = " | "
    # Update only if our key matches.
    match key:
        "profile_name", "author_name", "extra_notes":
            if not mcc.profile_dict["profile_name"].empty():
                notes_string += mcc.profile_dict["profile_name"]
            
            if not mcc.profile_dict["author_name"].empty():
                if not notes_string.empty():
                    notes_string += sep
                notes_string += "By " + mcc.profile_dict["author_name"]
            
            if not mcc.profile_dict["extra_notes"].empty():
                if not notes_string.empty():
                    notes_string += sep
                notes_string += mcc.profile_dict["extra_notes"]
            
            $HBox/ProfileNotes.text = notes_string
