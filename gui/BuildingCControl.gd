extends HBoxContainer

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# Called when the node enters the scene tree for the first time.
func _ready():
    $"%RegenerateButton".connect("pressed", mcc, "regenerate_texture_c")

    # For each enum value in our window algorithms enum, add it as a selectable
    # option. Use the enum's value for the item's ID. That means the enum's
    # value will end up in the configured key in the profile.
    for enum_val in GlobalRef.WindowAlgorithm:
        $"%AlgorithmOption".add_item(
            str(enum_val).capitalize(), GlobalRef.WindowAlgorithm[enum_val]
        )
