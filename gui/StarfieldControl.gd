extends VBoxContainer

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# Emitted when the user presses the "regenerate" button
signal regenerate()

func _on_RegenerateButton_pressed():
    emit_signal("regenerate")
