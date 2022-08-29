extends MeshInstance

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# Load the three different meterial types
const TypeAMat = preload("res://effects/BeaconTypeA.tres")
const TypeBMat = preload("res://effects/BeaconTypeB.tres")
const TypeCMat = preload("res://effects/BeaconTypeC.tres")

# What's the maximum value we'll accept for an occurrence rating?
const OCCURRENCE_MAX = 100

# Get the MaterialColorControl
onready var mcc = get_node("/root/MaterialColorControl")

# The different beacon types, which line up one-for-one with our three different
# materials. We have three different materials so we can vary the color,
# texture, and size.
enum BeaconType {A = 0, B = 1, C = 2}

# What is the current height of this beacon, as measured in building-windows?
var curr_beacon_height = 0 setget set_curr_beacon_height
# Beacons aren't usually set exacty at the corner of buildings - they're usually
# up-or-down a bit. We'll use this variable as a scalar against the window
# height constant to move the beacon up or down a bit. This can help with both
# aesthetics and with clipping issues.
var height_correction = .25 setget set_height_correction
# What is the type of this Beacon? This determines the material we use.
var type = BeaconType.A setget set_type
# What is the occurrence rating for this beacon? If this value is greater than
# the global occurrence value, then the node will be hidden.
var occurrence = 0 setget set_occurrence

# Is this beacon enabled? Because we directly manipulate the visible variable,
# we need this extra variable to control whether we're showing & hiding the
# beacons.
var enabled = false setget set_enabled

func _ready():
    beacon_update()

func set_type(new_type):
    type = new_type
    match type:
        BeaconType.A:
            self.set_surface_material(0, TypeAMat)
            self.add_to_group(GlobalRef.beacon_group_a)
            self.height_correction = mcc.profile_dict["beacon_correction_a"]
        BeaconType.B:
            self.set_surface_material(0, TypeBMat)
            self.add_to_group(GlobalRef.beacon_group_b)
            self.height_correction = mcc.profile_dict["beacon_correction_b"]
        BeaconType.C:
            self.set_surface_material(0, TypeCMat)
            self.add_to_group(GlobalRef.beacon_group_c)
            self.height_correction = mcc.profile_dict["beacon_correction_c"]

func set_curr_beacon_height(new_height):
    curr_beacon_height = new_height
    beacon_update()

func set_height_correction(new_correction):
    height_correction = new_correction
    beacon_update()

func set_occurrence(new_rating):
    occurrence = new_rating % (OCCURRENCE_MAX + 1)
    beacon_update()

func set_enabled(new_enable):
    enabled = new_enable
    beacon_update()

# Updates whether the beacon is visible or not. This is a separate function so
# we can take advantage of Godot's call_group() function, initiating updates
# en-masse.
func beacon_update():
    # Is this beacon going to be visibile or not? We have a lot of tests we need
    # to perform so we'll use this variable to store our result
    var viz = false
    
    # Adjust the beacon according to the building's height
    self.translation.y = GlobalRef.WINDOW_UV_SIZE * curr_beacon_height
    self.translation.y += GlobalRef.WINDOW_UV_SIZE * height_correction
    
    if self.mcc == null:
        return
    
    if not "beacon_min_height" in mcc.profile_dict:
        return
    
    if not "beacon_max_height" in mcc.profile_dict:
        return
    
    if not "beacon_occurrence" in mcc.profile_dict:
        return
    
    # We're visible if we pass a whole bunch of tests.
    # First, are we at-or-above the minimum height?
    viz = curr_beacon_height >= mcc.profile_dict["beacon_min_height"]
    # Second, are we at-or-below the maximum height?
    viz = viz and curr_beacon_height <= mcc.profile_dict["beacon_max_height"]
    # Third, is our occurrence rating at-or-below the global ocurrence rating?
    viz = viz and occurrence <= mcc.profile_dict["beacon_occurrence"]
    # Finally, is this enabled?
    self.visible = viz and enabled
