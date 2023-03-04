
# This script creates the city lights, which are integral to the city's
# look-and-feel.

# Load the GlobalRef script so we have that
const GlobalRef = preload("res://util/GlobalRef.gd")

# Class definition for our light data
class LightData:
    # What's the range of the light, in window units?
    var size
    # What's the group of this light? This determines the color.
    var group

# Determine the size, position, and group for each light.
static func make_blueprint(blueprint : Dictionary):
    # Grab the Random Number Generator so we don't need to constantly peek the
    # dictionary.
    var rng = blueprint["rngen"]
    
    # Create a new array of lights - one per corner.
    blueprint["lights"] = [
        LightData.new(), # Southeast
        LightData.new(), # Northeast
        LightData.new(), # Northwest
        LightData.new()  # Southwest
    ]
    
    # TODO: Remove some lights? Could look good, could look bad.
    
    # For each light...
    for light in blueprint["lights"]:
        
        # Set the size, in world units. We'll roll a random length based on the
        # building's height.
        light.size = rng.randf_range(
            blueprint["len_y"] * .6, blueprint["len_y"] * 1.60
        )
        
        # The range needs to be a whole value, so round it
        light.size = round( light.size )
        
        # Set the light's group designation, a number between one and four.
        light.group = (rng.randi() % 4) + 1

static func make_construction(building : Spatial, blueprint : Dictionary):
    # Lights now need to be packed into meshes at construction time - so there's
    # nothing for us to do here!
    pass
