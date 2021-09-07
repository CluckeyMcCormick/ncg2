tool
extends Spatial

# Grab the DebugDraw Node - this will allow us to debug shapes.
onready var dd = get_node("/root/DebugDraw")

export(float) var width = 20.25 setget set_width
export(float) var height = 12 setget set_height

func set_width(new_width):
    width = new_width
    $FieldMesh.mesh.size.x = width

    generate_field_a()
    generate_field_b()
    generate_field_c()

func set_height(new_height):
    height = new_height
    $FieldMesh.mesh.size.y = height
    $FieldMesh.translation.y = -height / 2

    generate_field_a()
    generate_field_b()
    generate_field_c()

# Called when the node enters the scene tree for the first time.
func _ready():
    generate_field_a()
    generate_field_b()
    generate_field_c()

func generate_field_a():
    _generate_field($FieldA.multimesh)

func generate_field_b():
    _generate_field($FieldB.multimesh)

func generate_field_c():
    _generate_field($FieldC.multimesh)

func _generate_field(field_multi):
    
    var new_transform
    
    # Set the transform of the instances.
    for i in field_multi.instance_count:
        new_transform = Transform(Basis(), Vector3(0, 0, 0))
        new_transform = new_transform.translated(Vector3(
            rand_range(-width / 2, width / 2),
            rand_range(-height, 0),
            0
        ))
        
        field_multi.set_instance_transform(i, new_transform)
