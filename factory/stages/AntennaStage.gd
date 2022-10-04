
# This stage generates some atennae for each building.

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# Load the Antenna script
const AntennaScript = preload("res://decorations/Antenna.gd")

# How many atennae do we generate, per building?
const ANTENNAE_COUNT = 6

# Okay, so we want taller antennae on taller buildings and shorter antennae on
# shorter buildings. Makes sense, right? To do that, we'll use this ratio...
# scalar... thing. This should scale down some antennae while scaling up other
# antenna. Hopefully, we can eventually get this integrated into the actuall
# antenna class itself.
const HEIGHT_RATIO_SCALAR = 1.0 / 30.0

# What's the minimum base height we'll generate for an antenna, in window units?
const GEN_MIN_HEIGHT = 1
# What's the maximum base height we'll generate for an antenna, in window units?
const GEN_MAX_HEIGHT = 3

# Class definition for our antenna data
class AntennaData:
    # What's the type of this antenna?
    var type
    # What's the occurrence rating for this antenna?
    var occurrence
    # What's the width of this antenna, in window units?
    var width
    # What's the base height of this antenna, in window units?
    var base_height
    # What's the offset of this antenna on X, in window units?
    var offset_x
    # What's the offset of this antenna on Z, in window units?
    var offset_z

# Plan out each antenna
static func make_blueprint(blueprint : Dictionary):
    # Our current antennae data
    var data = null
    
    # Our type choices; need these in an array so we can easily pick them at
    # random.
    var type_choices = AntennaScript.AntennaType.values()
    
    # What's the maximum possible size, in window units, that a box can be on
    # x and z? We subtract 2 to get away from the very edges of the building
    var max_x = blueprint["len_x"] - 2
    var max_z = blueprint["len_z"] - 2
    
    # Get our random number generator
    var rng = blueprint["rngen"]
    
    # Create an empty antennae array
    blueprint["antennae"] = []

    # Now, for each antenna we're supposed to make...
    for i in range(ANTENNAE_COUNT):
        # Make a new object for it
        data = AntennaData.new()
        
        # Pick a random type
        data.type = type_choices[ rng.randi() % len(type_choices) ]
        
        # Roll a random occurrence
        data.occurrence = rng.randi() % AntennaScript.OCCURRENCE_MAX
        
        # Width is currently fixed
        data.width = 1
        
        # Roll a random base height
        data.base_height = rng.randf_range(GEN_MIN_HEIGHT, GEN_MAX_HEIGHT)
        
        # Generate a random offset on X
        data.offset_x = rng.randf_range(
            -(max_x - data.width ) / 2.0,
             (max_x - data.width ) / 2.0
        )
        
        # Generate a random offset on Z
        data.offset_z = rng.randf_range(
            -(max_z - data.width ) / 2.0,
             (max_z - data.width ) / 2.0
        )
        
        # Add the data
        blueprint["antennae"].append(data)

# Construct each antenna
static func make_construction(building : Spatial, blueprint : Dictionary):
    # Load the Antenna scene
    var AntennaScene = load("res://decorations/Antenna.tscn")
    
    # Get the MaterialColorControl, using the building
    var mcc = building.get_node("/root/MaterialColorControl")
    
    # Grab the Tower FX node
    var towerFX = building.get_node("AutoTower/BuildingFX")
    
    # What's the current Antenna we're trying to add?
    var ante
    
    # What's the current id?
    var id = 1
    
    # For each box we're supposed to make...
    for data in blueprint["antennae"]:
        # Create a new box
        ante = AntennaScene.instance()
        
        # Add it!
        towerFX.add_child(ante)
        
        # So we have three separate types of antennae - except we also have
        # three different types of building, which can be different colors. What
        # that ends up meaning is that we need to have nine materials overall.
        # And THAT's why we have this match-within-match thing happening.
        match blueprint["material_enum"]:
            GlobalRef.BuildingMaterial.A:
                match data.type:
                    AntennaScript.AntennaType.ONE:
                        ante.set_surface_material(0, mcc.antennae_mat_a1)
                    AntennaScript.AntennaType.TWO:
                        ante.set_surface_material(0, mcc.antennae_mat_a2)
                    AntennaScript.AntennaType.THREE:
                        ante.set_surface_material(0, mcc.antennae_mat_a3)
            GlobalRef.BuildingMaterial.B:
                match data.type:
                    AntennaScript.AntennaType.ONE:
                        ante.set_surface_material(0, mcc.antennae_mat_b1)
                    AntennaScript.AntennaType.TWO:
                        ante.set_surface_material(0, mcc.antennae_mat_b2)
                    AntennaScript.AntennaType.THREE:
                        ante.set_surface_material(0, mcc.antennae_mat_b3)
            GlobalRef.BuildingMaterial.C:
                match data.type:
                    AntennaScript.AntennaType.ONE:
                        ante.set_surface_material(0, mcc.antennae_mat_c1)
                    AntennaScript.AntennaType.TWO:
                        ante.set_surface_material(0, mcc.antennae_mat_c2)
                    AntennaScript.AntennaType.THREE:
                        ante.set_surface_material(0, mcc.antennae_mat_c3)
        # Set the type
        ante.type = data.type
        
        # Set the occurrence
        ante.occurrence = data.occurrence
        
        # Set the roof height
        ante.roof_height = blueprint["len_y"]
        
        # Set the width
        ante.width = data.width
        
        # Set the base height
        ante.base_height = data.base_height
        
        # Shift the antenna around 
        ante.transform.origin.x = data.offset_x * GlobalRef.WINDOW_UV_SIZE
        ante.transform.origin.z = data.offset_z * GlobalRef.WINDOW_UV_SIZE
        
        # Set the count ID
        ante.count_id = id
        
        # Increment the ID
        id += 1
