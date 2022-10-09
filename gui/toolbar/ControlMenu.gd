extends MenuButton

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

const shortcut_camera_pause = preload("res://gui/ShortCut_CameraPause.tres")
const shortcut_effect_pause = preload("res://gui/ShortCut_EffectPause.tres")
const shortcut_toggle_gui = preload("res://gui/ShortCut_ToggleGUI.tres")

# The menu items are fixed, with fixed IDs, so we need these constants to refer
# to them.
const CAMERA_ID = 0
const EFFECT_ID = 10
const GUI_ID = 20

# Signals for the different menu options. These can either be operated directly
# or via a button press (through ShortCuts)
signal toggle_camera_pause()
signal toggle_effect_pause()
signal toggle_gui()

# Called when the node enters the scene tree for the first time.
func _ready():
    # First, get the pop-up menu
    var popup = self.get_popup()
    # Connect to the id_pressed signal so we know when the user did something.
    popup.connect("id_pressed", self, "_on_popup_id_pressed")
    
    # TODO: Figure out shortcuts; I'm worried how I'm doing it right now is
    # incompatible with international keyboards.
    
    # Now add the pop-ups
    popup.add_shortcut(shortcut_camera_pause, CAMERA_ID)
    popup.set_item_text(0, "Toggle Camera Pause")
    popup.add_shortcut(shortcut_effect_pause, EFFECT_ID)
    popup.set_item_text(1, "Toggle Effect Pause")
    popup.add_separator()
    popup.add_shortcut(shortcut_toggle_gui, GUI_ID)
    popup.set_item_text(3, "Toggle GUI")

func _on_popup_id_pressed(id):
    match id:
        CAMERA_ID:
            emit_signal("toggle_camera_pause")
        EFFECT_ID:
            emit_signal("toggle_effect_pause")
        GUI_ID:
            emit_signal("toggle_gui")
