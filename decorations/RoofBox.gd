extends Spatial

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# What's the maximum value we'll accept for an occurrence rating?
const OCCURRENCE_MAX = 100

# The length (in total number of cells) of each side of the box. It's a
# rectangular prism, so we measure the length on each axis.
export(float) var len_x =  1 setget set_length_x
export(float) var len_y = .5 setget set_length_y
export(float) var len_z =  1 setget set_length_z

# The material we'll use to make this box.
export(Material) var material setget set_material

# What is the current height of this roof box, as measured in building-windows?
var roof_height = 0 setget set_roof_height

# What is the occurrence rating for this beacon? If this value is greater than
# the global occurrence value, then the node will be hidden.
var occurrence = 0 setget set_occurrence

# The roof boxes tend to look best when they are in proportion to their
# buildings: shorter boxes on shorter buildings and taller boxes on taller
# buildings. To do that, we use a "height ratio", which uses the buildings
# height in a ratio to create a scalar. So, when creating that ratio, what fixed
# value do we use as the denominator?
var height_ratio_denom = 30.0 setget set_height_ratio_denom
# If a building is LESS than this value in window-height, the box will be
# shorter than normal. If they are above this, the box will be taller.

# To be honest, sometimes the above height ratio isn't enough - so we have an
# ADDITIONAL scalar to scale up (or down!) the height even more.
var extra_scalar = 1.0 setget set_extra_scalar

# Sometimes, we want to limit the number of antennae found on a roof. To do
# that, we assign each antennae a count ID - we'll then exclude those that go
# above a certain count.
var count_id = 0

func _ready():
    # Stick this roof box in general box group
    self.add_to_group( GlobalRef.box_group )

# --------------------------------------------------------
#
# Setters and Getters
#
# --------------------------------------------------------
func set_length_x(new_length):
    len_x = new_length
    _size_update()

func set_length_y(new_length):
    len_y = new_length
    _size_update()
    
func set_length_z(new_length):
    len_z = new_length
    _size_update()

func set_material(new_material):
    material = new_material
    $Box.set_surface_material(0, material)

func set_roof_height(new_height):
    roof_height = new_height
    _pos_update()
    _visual_update()

func set_occurrence(new_rating):
    occurrence = new_rating % (OCCURRENCE_MAX + 1)
    _visual_update()

func set_height_ratio_denom(new_denom):
    if new_denom == 0.0:
        printerr("Antennae height ratio denominator must be non-zero!")
        return
    height_ratio_denom = new_denom
    _size_update()

func set_extra_scalar(new_extra_scalar):
    extra_scalar = new_extra_scalar
    _size_update()

# --------------------------------------------------------
#
# Update Functions
#
# --------------------------------------------------------   

# Updates the Roof Box's local variables to match the values in the MCC for the
# Roof Box's current type.
func _mcc_update():
    self.extra_scalar = mcc.profile_dict["box_extra"]
    self.height_ratio_denom = mcc.profile_dict["box_denominator"]

func _size_update():
    var ratio = 1
    
    # If we have a MCC, and the box ratio key is actually in the MCC, and the
    # box ratio nonsense is enabled...
    if mcc != null and "box_ratio_enabled" in mcc.profile_dict and \
    mcc.profile_dict["box_ratio_enabled"]:
        # Set the ratio scalar
        ratio = float(roof_height) / float(height_ratio_denom)
    
    # Set the length/scale on X
    $Box.scale.x = GlobalRef.WINDOW_UV_SIZE * len_x
    
    # Set the length/scale on Y AND adjust the translation
    $Box.scale.y = GlobalRef.WINDOW_UV_SIZE * len_y * ratio * extra_scalar
    $Box.translation.y = $Box.scale.y / 2.0
    
    # Set the length/scale on Z
    $Box.scale.z = GlobalRef.WINDOW_UV_SIZE * len_z

func _pos_update():
    # Adjust the roof box according to the building's height
    self.translation.y = GlobalRef.WINDOW_UV_SIZE * roof_height

func _visual_update():
    # Is this box going to be visibile or not? We have a lot of tests we need
    # to perform so we'll use this variable to store our result
    var viz = false
    
    if self.mcc == null:
        return
    
    if not "box_min_height" in mcc.profile_dict:
        return
    
    if not "box_max_height" in mcc.profile_dict:
        return
    
    if not "box_occurrence" in mcc.profile_dict:
        return
    
    if not "box_enabled" in mcc.profile_dict:
        return
    
    if not "box_max_count" in mcc.profile_dict:
        return
    
    # We're visible if we pass a whole bunch of tests.
    # First, are we at-or-above the minimum height?
    viz = roof_height >= mcc.profile_dict["box_min_height"]
    # Second, are we at-or-below the maximum height?
    viz = viz and roof_height <= mcc.profile_dict["box_max_height"]
    # Third, is our occurrence rating at-or-below the global ocurrence rating?
    viz = viz and occurrence <= mcc.profile_dict["box_occurrence"]
    # Fourth, are we at-or-below the global max count?
    viz = viz and count_id <= mcc.profile_dict["box_max_count"]
    # Finally, is this enabled?
    $Box.visible = viz and mcc.profile_dict["box_enabled"]

# The "Total Update" function takes values from the MCC and then applies the
# appropriate position and visual updates. This function is required to avoid
# lagtime when doing enmasse updates.
func total_update():
    _mcc_update()
    _pos_update()
    _size_update()
    _visual_update()
