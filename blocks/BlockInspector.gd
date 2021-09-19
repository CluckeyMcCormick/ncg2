extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    $CameraPivot/Tween.interpolate_property(
        $CameraPivot, "rotation_degrees:y", 0, 360, 5,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
    )
    $CameraPivot/Tween.start()
