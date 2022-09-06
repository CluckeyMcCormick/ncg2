extends MeshInstance

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# What's the maximum value we'll accept for an occurrence rating?
const OCCURRENCE_MAX = 100

# The width and height (in total number of cells) of this antennae. This is
# achieved by manipulating the scale of the node, so try not to mess with the
# scale of this node!
var width = 1.0 setget set_width
var height = 2.0 setget set_height

# What is the current height of this Antenna, as measured in building-windows?
var roof_height = 0 setget set_roof_height

# NOTE: There was a lot of inner turmoil for

func set_roof_height(new_height):
    roof_height = new_height
    
    # Adjust the beacon according to the building's height
    self.translation.y = GlobalRef.WINDOW_UV_SIZE * roof_height

func set_width(new_width):
    width = new_width
    self.scale.x = GlobalRef.WINDOW_UV_SIZE * width

func set_height(new_height):
    height = new_height
    self.scale.y = GlobalRef.WINDOW_UV_SIZE * height
