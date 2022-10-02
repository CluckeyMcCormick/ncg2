extends MeshInstance

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# What's the maximum value we'll accept for an occurrence rating?
const OCCURRENCE_MAX = 100

# We support three types of antennae.
enum AntennaType {ONE = 1, TWO = 2, THREE = 3}

# What is the type of this Antenna? This determines our group
var type = AntennaType.ONE setget set_type

# What is the occurrence rating for this antenna? If this value is greater than
# the global occurrence value, then the node will be hidden.
var occurrence = 0 setget set_occurrence

# Is this antenna enabled? Because we directly manipulate the visible variable,
# we need this extra variable to control whether we're showing & hiding the
# beacons.
var enabled = true setget set_enabled

# The desired width and height of the antennae are achieved by manipulating the
# scale of the node, so try not to mess with the scale outside of the functions
# in this node!

# The width (in total number of cells) of this antennae.
var width = 1.0 setget set_width
# The base height (in total number of cells) of this antennae. This is the
# "base" height because this is what gets multiplied by the height ratio and
# extra scalar.
var base_height = 2.0 setget set_base_height
# The antennae tend to look best when they are in proportion to their buildings:
# shorter antennae on shorter buildings and taller antennae on taller buildings.
# Do to do that, we use a "height ratio", which uses the buildings height in a
# ratio to create a scalar. So, when creating that ratio, what fixed value do
# we use as the denominator. If a building is LESS than this value in
# window-height, the antennae will be shorter than normal. If they are bove
# this, they will be taller than normal.
var height_ratio_denom = 30.0 setget set_height_ratio_denom
var height_ratio_enable = true setget set_height_ratio_enable

# To be honest, sometimes the above height ratio isn't enough - so we have an
# ADDITIONAL scalar to scale up (or down!) the height even more.
var extra_scalar = 1.0 setget set_extra_scalar

# What is the current height of this Antenna, as measured in building-windows?
var roof_height = 0 setget set_roof_height

#########################################
#
# TYPE, OCCURRENCE, AND ENABLED FUNCTIONS
#
#########################################
func set_type(new_type):
    type = new_type

    # Clear our old groups
    for group in self.get_groups():
        self.remove_from_group(group)

    # Set up our groups
    match type:
        AntennaType.ONE:
            self.add_to_group(GlobalRef.antenna_group_a)
        AntennaType.TWO:
            self.add_to_group(GlobalRef.antenna_group_b)
        AntennaType.THREE:
            self.add_to_group(GlobalRef.antenna_group_c)
    
    # Perform a visual update
    _visual_update()

func set_occurrence(new_rating):
    occurrence = new_rating % (OCCURRENCE_MAX + 1)
    _visual_update()

func set_enabled(new_enable):
    enabled = new_enable
    _visual_update()

func _visual_update():
    self.visible = enabled

##########################
#
# HEIGHT & WIDTH FUNCTIONS
#
##########################
func set_width(new_width):
    width = new_width
    self.scale.x = GlobalRef.WINDOW_UV_SIZE * width

func set_roof_height(new_height):
    roof_height = new_height
    
    # Adjust the antenna's position according to the building's height
    self.translation.y = GlobalRef.WINDOW_UV_SIZE * roof_height
    
    # Update the height of the antenna
    _adjust_height()

func set_base_height(new_height):
    base_height = new_height
    _adjust_height()

func set_height_ratio_denom(new_denom):
    if new_denom == 0.0:
        printerr("Antennae height ratio denominator must be non-zero!")
        return
    height_ratio_denom = new_denom

func set_height_ratio_enable(new_enable):
    height_ratio_enable = new_enable
    _adjust_height()

func set_extra_scalar(new_extra_scalar):
    extra_scalar = new_extra_scalar
    _adjust_height()

# This function adjusts the scale of the antenna so that it ends up as the
# appropriate height.
func _adjust_height():
    # What's our new scale for the antennae? 
    var new_scale = GlobalRef.WINDOW_UV_SIZE * base_height
    
    # If we're calculating using the height ratio, then calculate using the
    # height ratio!
    if height_ratio_enable:
        new_scale *= float(roof_height) / float(height_ratio_denom)
    
    # Use our extra scalar too boot.
    new_scale *= extra_scalar
    
    # Set the new scale
    self.scale.y = new_scale
