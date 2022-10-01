
# This script creates the city lights, which are integral to the city's
# look-and-feel.
const GlobalRef = preload("res://util/GlobalRef.gd")

# We include the radius of the lights when calculating the building's Visibility
# AABB (which determines if we're on screen or not). However, it's been observed
# that sometimes the building loads in but the lights won't load until later. To
# get around that, we'll use this scalar to increase the light radius included
# in the AABB - that means the buildings will load in sooner, and so too will
# their lights.
const LIGHT_SCALAR = 2

# Class definition for our light data
class LightData:
    # What's the size of the light, in window units?
    var size
    # What's the group of this light? This determines the color.
    var group
    # What's the position of this light, in realspace units?
    var pos

# This function gets called first, in the blueprint stage. This one will most
# likely be run from a thread, so you must avoid creating nodes in it. This is
# where the "planning" should take place, and can be algorithmically complex as
# you need - after all, it's threaded. Any values you wish to carry over to the
# construction stage should be placed in the blueprint Dictionary.
static func make_blueprint(blueprint : Dictionary):
    # Declare our light positions ahead of time.
    var light_positions = [
        Vector2( blueprint["footprint_x"],  blueprint["footprint_z"]),
        Vector2(-blueprint["footprint_x"],  blueprint["footprint_z"]),
        Vector2( blueprint["footprint_x"], -blueprint["footprint_z"]),
        Vector2(-blueprint["footprint_x"], -blueprint["footprint_z"])
    ]
    
    # Grab the Random Number Generator so we don't need to constantly peek the
    # dictionary.
    var rng = blueprint["rngen"]
    
    # The current light we're working on.
    var light = null
    
    # Create a new arrays to track the lights
    blueprint["lights"] = []
    
    # For each light...
    for pos in light_positions:
        # Create a new light
        light = LightData.new()
        
        # Set the size, in world units. We want the light to climb part of the
        # building, so we'll go between 1/4 and 3/4 of the building's total
        # height.
        light.size = rng.randf_range(
            blueprint["len_y"] * .25, blueprint["len_y"] * .75
        )
        
        # Set the light's group designation, a number between one and four.
        light.group = rng.randi() % 4
        
        # Set the appropriate translation for the light.
        light.pos = pos * GlobalRef.WINDOW_UV_SIZE
        
        # Append the light data
        blueprint["lights"].append(light)

# This function gets called after make_blueprint, in the construction stage.
# This function wil not be run from a thread; here is where nodes are spawned
# and placed appropriately. However, it's not threaded, so take care and ensure
# the function isn't too complex. The provided building is a TemplateBuilding,
# any modifications should be made to that node. The blueprint dictionary is the
# same one from the make_blueprint function call.
static func make_construction(building : Spatial, blueprint : Dictionary):
    # Load the CityLight scene
    var CityLight = load("res://decorations/CityLight.tscn")
    
    # Get the Visibility node
    var visi = building.get_node("VisibilityNotifier")
    
    # Get the Footprint Effects node, which is where we're supposed to put
    # footprint-aligned decorations.
    var ftpfx = building.get_node("FootprintFX")
    
    # We'll need to include the lights in the visibility AABB, which means we'll
    # need to adjust the position and size of the visibility AABB. And to do
    # THAT, we'll need to know the size of the footprint (in real-units)
    var fp_x = blueprint["footprint_x"] * GlobalRef.WINDOW_UV_SIZE
    var fp_z = blueprint["footprint_z"] * GlobalRef.WINDOW_UV_SIZE
    
    # What's the maximum AABB-length on x and z that we'll need?
    var max_x = fp_x
    var max_z = fp_z
    
    # The range of an OmniLight doesn't scale up and down with... scale, so we
    # need to do it manually. And to do that, we'll calculate the effective
    # scalar for the omni-light.
    # This is a horrendously lazy way of doing it, but it works for what I need.
    var eff_scalar = abs( 
        (blueprint["scale"].x + blueprint["scale"].y + blueprint["scale"].z) / 2
    )
    
    # For each piece of light data...
    for light_data in blueprint["lights"]:
        # Create a new light
        var light = CityLight.instance()
        
        # Set the range
        light.omni_range = light_data.size * GlobalRef.WINDOW_UV_SIZE
        
        # Stick the light under the footprint's FX manager
        ftpfx.add_child(light)
        
        # Now that the light is in the scene, it should have access to the MCC;
        # ergo we can safely set the type.
        match light_data.group:
            0:
                light.type = light.LightCategory.ONE
            1:
                light.type = light.LightCategory.TWO
            2:
                light.type = light.LightCategory.THREE
            3:
                light.type = light.LightCategory.FOUR
        
        # Shift the light appropriately
        light.translation = Vector3( light_data.pos.x, 0, light_data.pos.y )
        
        # We're going to do this as lazily as possible: Let's say, in this
        # diagram, B & Y are the edges of the building. A is the farthest point
        # reached by a light at B. Z is the farthest point reached by a light at
        # Z. We can observe:
        #                       A-------B#####Y-------Z
        # Basically, we need to update the effective x and z such that they
        # encompass A through Z. That means doubling the omni_radius and adding
        # it onto the length of the appropriate side of the footprint.
        max_x = max(
            fp_x + (light.omni_range * 2 * LIGHT_SCALAR), 
            max_x
        )
        max_z = max(
            fp_z + (light.omni_range * 2 * LIGHT_SCALAR), 
            max_z
        )
        
        # Now, after all that, apply the effective scalar. Our AABB will scale,
        # but not the light's range.
        light.omni_range *= eff_scalar
    
    # Update the visibility's AABB position and size based on our light
    # adjustments
    visi.aabb.position.x = -max_x / 2.0
    visi.aabb.position.z = -max_z / 2.0
    visi.aabb.size.x = max_x
    visi.aabb.size.z = max_z
