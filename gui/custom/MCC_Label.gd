extends Label
class_name MCCLabel

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# What's the Material Color Control Key property we're targeting?
export(String) var target_key

func _ready():
    # Connect to the key update signal, so we can respond to key changes.
    mcc.connect("key_update", self, "_on_mcc_key_update")

func _on_mcc_key_update(key):
    # Update only if our key matches - if the key matches, then we assume the
    # value there-in is a string.
    match key:
        target_key:
                self.text = mcc.profile_dict[key]
