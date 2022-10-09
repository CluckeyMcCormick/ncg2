extends LineEdit
class_name MCCLineEdit

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# What's the Material Color Control Key property we're targeting?
export(String) var target_key

# Do we update the global profile to reflect our values whenever a value gets
# updated? We need this to stop ourselves from accidentally looping forever.
var _update_global = true

# Are we updating ourselves? We'll use this stop ourselves from double-changing
# the text
var _updating_self = false

func _ready():
    # Connect to the key update signal, so we can respond to key changes.
    mcc.connect("key_update", self, "_on_mcc_key_update")
    # Connect to our own "text_changed" signal. We do this in code to ensure
    # the user doesn't accidentally disconnect the signal when including this in
    # a scene.
    self.connect("text_changed", self, "_on_text_changed_mcc")

func _on_mcc_key_update(key):
    # Disable updating the globabl dictionary - we don't want to update
    # something while we're reading from it!
    _update_global = false
    
    # Update only if our key matches - if the key matches, then we assume the
    # value there-in is a string. DO NOT update our text if we were in the
    # middle of a text update.
    match key:
        target_key:
            if not _updating_self:
                self.text = mcc.profile_dict[key]

    # Enable global updating again
    _update_global = true

func _on_text_changed_mcc(new_text):
    # We're updating ourselves, so set updating self to true
    _updating_self = true
    
    # Update global
    if _update_global:
        mcc.profile_dict[target_key] = new_text
        mcc.update_key(target_key)
    
    # All done, no longer updating
    _updating_self = false
