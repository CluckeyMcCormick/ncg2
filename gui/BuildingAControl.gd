extends HBoxContainer

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# Called when the node enters the scene tree for the first time.
func _ready():
    $"%RegenerateButton".connect("pressed", mcc, "regenerate_texture_a")
