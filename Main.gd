extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    $Tween.interpolate_property($Spin, "rotation_degrees:y",
        0, 360, 4,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.start()
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
