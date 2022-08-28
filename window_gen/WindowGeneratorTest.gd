extends Node2D

const BUILDING_SIZE = 4096
const WINDOW_SIZE = 64

const WIN_GEN = preload("res://window_gen/WindowGenerator.gd")

var WINDOW_IMAGE = preload("res://window_gen/windows/bar_vertical_50p.png").get_data()

# Called when the node enters the scene tree for the first time.
func _ready():
    var gennie = WIN_GEN.WindowGenerator.new()
    
    gennie.paint_anti_diagonal([WINDOW_IMAGE])
    
    $Dots64Horizontal64100h.texture = gennie.texture


