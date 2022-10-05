
# This script creates the roof top boxes, which I guess are supposed to be AC
# units or stairwells or... something. These shapes help to make the building's
# silhouettes more varied

# Load the GlobalRef script so we have that
const GlobalRef = preload("res://util/GlobalRef.gd")

# Load the RoofBox script so we can refer to that when we need to.
const RoofBoxScript = preload("res://decorations/RoofBox.gd")

# What's the minimum height for a Roof Box, in window units?
const HEIGHT_MIN = .375
# What's the maximum height for a Roof Box, in window units?
const HEIGHT_MAX = 1.5

# Sometimes the rooftop boxes are far too small - they end up looking
# just wrong. So we won't even ALLOW a rooftop box if it is LESS THAN this
# value.
const MIN_BOX_LEN = 2

# How many boxes do we spawn per roof?
const BOX_COUNT = 5

# Class definition for our Roof Box data
class RoofBoxData:
    # What's the length of the box on x, in window units?
    var len_x
    # What's the length of the box on y, in window units?
    var len_y
    # What's the length of the box on z, in window units?
    var len_z
    
    # What's the occurrence rating for this Roof Box?
    var occurrence
    
    # What's the offset of this Roof Box from the building's center on X, in
    # window units?
    var offset_x

    # What's the offset of this Roof Box from the building's center on Z, in
    # window units?
    var offset_z

# Determine how many roof boxes we have, as well as their size, occurrence
# rating, and offset.
static func make_blueprint(blueprint : Dictionary):
    # Our current box data
    var box_data = null
    
    # What's the maximum possible size, in window units, that a box can be on
    # x and z? We subtract 2 to get away from the very edges of the building
    var max_x = blueprint["len_x"] - 2
    var max_z = blueprint["len_z"] - 2
    
    # Get our random number generator
    var rng = blueprint["rngen"]
    
    # Create an empty roof boxes array
    blueprint["roof_boxes"] = []
    
    # If our maximum possible box is TOO SMALL, back out. We just won't have any
    # roof boxes.
    if max_x < MIN_BOX_LEN or max_z < MIN_BOX_LEN:
        return
    
    # Now, for each box we're supposed to make...
    for i in range(BOX_COUNT):
        # Make a new object for it
        box_data = RoofBoxData.new()
        
        # Roll a random length on X and Z
        box_data.len_x = rng.randi_range(MIN_BOX_LEN, max_x)
        box_data.len_z = rng.randi_range(MIN_BOX_LEN, max_z)
        
        # Roll a random length on Y
        box_data.len_y = rng.randi_range(HEIGHT_MIN, HEIGHT_MAX)
        
        # Roll a random occurrence
        box_data.occurrence = rng.randi_range(
            0, RoofBoxScript.OCCURRENCE_MAX
        )
        
        # Generate a random offset on X
        box_data.offset_x = rng.randf_range(
            -(max_x - box_data.len_x ) / 2.0,
             (max_x - box_data.len_x ) / 2.0
        )
        
        # Generate a random offset on Z
        box_data.offset_z = rng.randf_range(
            -(max_z - box_data.len_z ) / 2.0,
             (max_z - box_data.len_z ) / 2.0
        )
        
        # Add the data
        blueprint["roof_boxes"].append(box_data)

# Add the Roof Boxes into the scene and update them appropriately
static func make_construction(building : Spatial, blueprint : Dictionary):
    # Load the roof box scene
    var RoofBox = load("res://decorations/RoofBox.tscn")
    
    # Get the MaterialColorControl, using the building
    var mcc = building.get_node("/root/MaterialColorControl")
    
    # Grab the Tower FX node
    var towerFX = building.get_node("AutoTower/BuildingFX")
    
    # What's the current RoofBox we're trying to add?
    var box
    
    # What's the current id?
    var id = 1
    
    # For each box we're supposed to make...
    for box_data in blueprint["roof_boxes"]:
        # Create a new box
        box = RoofBox.instance()
        
        # Add it!
        towerFX.add_child(box)
        
        # Set the material appropriately given the material enum.
        match blueprint["material_enum"]:
            GlobalRef.BuildingMaterial.A:
                box.material = mcc.roofbox_mat_a
            GlobalRef.BuildingMaterial.B:
                box.material = mcc.roofbox_mat_b
            GlobalRef.BuildingMaterial.C:
                box.material = mcc.roofbox_mat_c
        
        # Set the count ID
        box.count_id = id
        
        # Set the height
        box.roof_height = blueprint["len_y"]
        
        # Set the occurrence
        box.occurrence = box_data.occurrence
        
        # Set the lengths of the box
        box.len_x = box_data.len_x
        box.len_y = box_data.len_y
        box.len_z = box_data.len_z
            
        # We're going to skip updating the box (via box_update) because setting
        # the roof height and occurrence should have called it already.
        
        # Move the box around
        box.translation.x += box_data.offset_x * GlobalRef.WINDOW_UV_SIZE
        box.translation.z += box_data.offset_z * GlobalRef.WINDOW_UV_SIZE

        # Increment the ID
        id += 1
