extends CheckBox

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# What's the Material Color Control Key property we're targeting?
export(String) var target_key

# Do we update the global profile to reflect our values whenever a value gets
# updated? We need this to stop ourselves from accidentally looping forever.
var _update_global = true

func _ready():
    # Connect to the key update signal, so we can respond to key changes.
    mcc.connect("key_update", self, "_on_mcc_key_update")
    # Connect to our own "on_pressed" signal. We do this in code to ensure the
    # user doesn't accidentally disconnect the signal when including this in a
    # scene.
    self.connect("toggled", self, "_on_toggled")

func _on_mcc_key_update(key):
    # Disable updating the globabl dictionary - we don't want to update
    # something while we're reading from it!
    _update_global = false
    
    # Update only if our key matches - if the key matches, then we assume the
    # value there-in is a boolean.
    match key:
        target_key:
            self.pressed = mcc.profile_dict[key]

    # Enable global updating again
    _update_global = true

func _on_toggled(button_pressed):
    if _update_global:
        mcc.profile_dict[target_key] = button_pressed
        mcc.update_key(target_key)
