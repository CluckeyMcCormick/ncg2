extends Spatial

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# What's the maximum value we'll accept for an occurrence rating?
const OCCURRENCE_MAX = 100

# The length (in total number of cells) of each side of the box. It's a
# rectangular prism, so we measure the length on each axis.
export(float) var len_x = 1 setget set_length_x
export(float) var len_y = .5 setget set_length_y
export(float) var len_z = 1 setget set_length_z

# The material we'll use to make this box.
export(Material) var material setget set_material

# What is the current height of this roof box, as measured in building-windows?
var roof_height = 0 setget set_roof_height

# What is the occurrence rating for this beacon? If this value is greater than
# the global occurrence value, then the node will be hidden.
var occurrence = 0 setget set_occurrence

# TODO: This object is having a massive impact on construction time. Recommend
# using the single mesh scaling that we currently use for Antennae. 

func _ready():
    # Stick this roof box in the box group
    self.add_to_group( GlobalRef.box_group )

# --------------------------------------------------------
#
# Setters and Getters
#
# --------------------------------------------------------
func set_length_x(new_length):
    len_x = new_length
    $AutoTower.len_x = len_x

func set_length_y(new_length):
    len_y = new_length
    $AutoTower.len_y = len_y
    
func set_length_z(new_length):
    len_z = new_length
    $AutoTower.len_z = len_z

func set_material(new_material):
    material = new_material
    $AutoTower.building_material = material

func set_roof_height(new_height):
    roof_height = new_height
    box_update()

func set_occurrence(new_rating):
    occurrence = new_rating % (OCCURRENCE_MAX + 1)
    box_update()

# --------------------------------------------------------
#
# Other Functions
#
# --------------------------------------------------------
func make_box():
    $AutoTower.make_building()
    
func box_update():
    # Is this box going to be visibile or not? We have a lot of tests we need
    # to perform so we'll use this variable to store our result
    var viz = false
    
    # Adjust the beacon according to the building's height
    self.translation.y = GlobalRef.WINDOW_UV_SIZE * roof_height
    
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
    
    # We're visible if we pass a whole bunch of tests.
    # First, are we at-or-above the minimum height?
    viz = roof_height >= mcc.profile_dict["box_min_height"]
    # Second, are we at-or-below the maximum height?
    viz = viz and roof_height <= mcc.profile_dict["box_max_height"]
    # Third, is our occurrence rating at-or-below the global ocurrence rating?
    viz = viz and occurrence <= mcc.profile_dict["box_occurrence"]
    # Finally, is this enabled?
    self.visible = viz and mcc.profile_dict["box_enabled"]
