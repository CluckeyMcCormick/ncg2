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
    $Box.scale.x = GlobalRef.WINDOW_UV_SIZE * len_x

func set_length_y(new_length):
    len_y = new_length
    $Box.scale.y = GlobalRef.WINDOW_UV_SIZE * len_y
    $Box.translation.y = $Box.scale.y / 2.0
    
func set_length_z(new_length):
    len_z = new_length
    $Box.scale.z = GlobalRef.WINDOW_UV_SIZE * len_z

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

# --------------------------------------------------------
#
# Update Functions
#
# --------------------------------------------------------   

# Updates the Roof Box's local variables to match the values in the MCC for the
# Roof Box's current type.
func _mcc_update():
    # As of this writing, the Roof Box has no MCC values it needs to retrieve
    # and store locally.
    pass

func _pos_update():
    # Adjust the beacon according to the building's height
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
    
    # We're visible if we pass a whole bunch of tests.
    # First, are we at-or-above the minimum height?
    viz = roof_height >= mcc.profile_dict["box_min_height"]
    # Second, are we at-or-below the maximum height?
    viz = viz and roof_height <= mcc.profile_dict["box_max_height"]
    # Third, is our occurrence rating at-or-below the global ocurrence rating?
    viz = viz and occurrence <= mcc.profile_dict["box_occurrence"]
    # Finally, is this enabled?
    $Box.visible = viz and mcc.profile_dict["box_enabled"]

# The "Total Update" function takes values from the MCC and then applies the
# appropriate position and visual updates. This function is required to avoid
# lagtime when doing enmasse updates.
func total_update():
    _mcc_update()
    _pos_update()
    _visual_update()
