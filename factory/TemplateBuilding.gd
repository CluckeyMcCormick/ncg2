extends Spatial

# Signal emitted when this building enters the screen - basically an echo of the
# VisibilityNotifier's screen_entered signal.
signal screen_entered(building)

# Ditto, but for when the building exits the screen.
signal screen_exited(building)

# We have two functions for setting this building to either "onscreen" mode or
# "offscreen" mode. We do this via a function instead of the "visible" variable
# because setting "visible" to false would disable the visibility notifier.
# Set the building to "ONSCREEN" mode.
func set_onscreen_mode():
    $AutoTower.visible = true
    $FootprintFX.visible = true

# Set the building to "OFFSCREEN" mode.  
func set_offscreen_mode():
    $AutoTower.visible = false
    $FootprintFX.visible = false

func _on_VisibilityNotifier_screen_entered():
    emit_signal("screen_entered", self)
    
func _on_VisibilityNotifier_screen_exited():
    emit_signal("screen_exited", self)
