tool
extends Spatial

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# Grab the DebugDraw Node - this will allow us to debug shapes.
onready var dd = get_node("/root/DebugDraw")

export(float) var width = 20.25 setget set_width
export(float) var height = 12 setget set_height

export(int) var field_a_count = 20 setget set_field_a_count
export(int) var field_b_count = 20 setget set_field_b_count
export(int) var field_c_count = 20 setget set_field_c_count

export(float) var scale_mean = .85 setget set_scale_mean
export(float) var scale_variance = .15 setget set_scale_variance

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

func set_field_a_count(new_count):
    field_a_count = new_count
    $FieldA.multimesh.instance_count = field_a_count
    
    generate_field_a()

func set_field_b_count(new_count):
    field_b_count = new_count
    $FieldB.multimesh.instance_count = field_b_count
    
    generate_field_b()
    
func set_field_c_count(new_count):
    field_c_count = new_count
    $FieldC.multimesh.instance_count = field_c_count
    
    generate_field_c()

func set_scale_mean(new_mean):
    scale_mean = new_mean
    
    generate_field_a()
    generate_field_b()
    generate_field_c()

func set_scale_variance(new_variance):
    scale_variance = new_variance
    
    generate_field_a()
    generate_field_b()
    generate_field_c()

# Called when the node enters the scene tree for the first time.
func _ready():
    generate_field_a()
    generate_field_b()
    generate_field_c()

func generate_field_a():
    if self.has_node("FieldA"):
        _generate_field($FieldA.multimesh)

func generate_field_b():
    if self.has_node("FieldB"):
        _generate_field($FieldB.multimesh)

func generate_field_c():
    if self.has_node("FieldC"):
        _generate_field($FieldC.multimesh)

func _generate_field(field_multi):
    
    var genny = RandomNumberGenerator.new()
    
    var new_transform
    var new_scale
    
    var ideal_pos
    
    # If this is in the editor, apply a seed so we get consistent results and
    # the scene file doesn't change CONSTANTLY. This will save our
    # source-control software some hassle.
    if Engine.editor_hint:
        genny.seed = hash("IN_ENGINE")
    else:
        genny.randomize()
    
    # Set the transform of the instances.
    for i in field_multi.instance_count:
        new_transform = Transform(Basis(), Vector3(0, 0, 0))
        
        new_scale = genny.randfn(scale_mean, scale_variance)
        
        # Catch to ensure our scale isn't zero
        if new_scale <= 0:
            new_scale = abs(new_scale) + .001
        
        new_transform = new_transform.scaled(Vector3(
            new_scale, new_scale, new_scale
        ))
        
        ideal_pos = Vector3(
            genny.randf_range(-width / 2, width / 2),
            genny.randf_range(-height, 0),
            0
        ) * (1.0 / new_scale) # Multiply by inverse scale, ensuring correct pos.
        
        new_transform = new_transform.translated(ideal_pos)
        
        field_multi.set_instance_transform(i, new_transform)
