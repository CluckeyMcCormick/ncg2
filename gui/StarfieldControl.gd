extends VBoxContainer

# Emitted when the user presses the "regenerate" button
signal regenerate()

func _on_RegenerateButton_pressed():
    emit_signal("regenerate")
