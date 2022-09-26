
# This script sets the capital-T Transform for the building - the rotation,
# the origin (position), and the scale. Of course we actually don't touch the
# scale but if we did we would do that here.

# In order to add more variation to the buildings, we randomly rotate the
# tower and then shrink it to fit in our footprint. However, we don't want to do
# that infinitely - how many times do we do that before we just give up and
# default to a non-rotation?
const MAX_MODIFICATIONS = 25

# What's the minimum thinness (in windows) we'll allow for one side of a
# building? This will (probably) stop us from getting weird ultra-thin
# buildings.
const MIN_THIN = 2

# When we randomly rotate a building, we clamp the result between -value and
# value. What is that value we clamp between? This should be 45 degrees because
# our buildings are rectangular - rotating it beyond -45/45 just looks like
# another rotated rectangle.
const MAX_ROTATION_DEGREES = 45

# This function gets called first, in the blueprint stage. This one will most
# likely be run from a thread, so you must avoid creating nodes in it. This is
# where the "planning" should take place, and can be algorithmically complex as
# you need - after all, it's threaded. Any values you wish to carry over to the
# construction stage should be placed in the blueprint Dictionary.
static func make_blueprint(blueprint : Dictionary):
    
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    
    # Now we want to rotate the building, but we need to make sure we stay in
    # the footprint. So, we'll use the four variables to ensure that the four
    # points of the building fall within the footprint.
    var a; var b; var c; var d
    
    # Boolean value - are we in the footprint?
    var in_print
    
    # How many times have we made a modification to try and fit the rotation? 
    var rot_mod_count = 0
    
    # What's our current rotation?
    var rotation
    
    # What's the size of our footprint?
    var fp_x = blueprint["footprint_x"]
    var fp_z = blueprint["footprint_z"]
    
    # What's the size of our building?
    var len_x = blueprint["len_x"]
    var len_z = blueprint["len_z"]
    
    # Okay, pick a random rotation.
    if true:
        rotation = clamp(
            rng.randfn(0.0, blueprint["rotation_deviation"]),
            -MAX_ROTATION_DEGREES, MAX_ROTATION_DEGREES
        )
    else:
        rotation = 0
    
    # Generate vector2 points according to the new lengths
    a = Vector2(-len_x / 2, -len_z / 2)
    b = Vector2( len_x / 2,  len_z / 2)
    c = Vector2(-len_x / 2,  len_z / 2)
    d = Vector2( len_x / 2, -len_z / 2)
    
    # Alright, figure out how these points look when rotated
    a = a.rotated(deg2rad(rotation))
    b = b.rotated(deg2rad(rotation))
    c = c.rotated(deg2rad(rotation))
    d = d.rotated(deg2rad(rotation))
    
    # Ensure these points are in the base footprint.
    in_print = in_footprint(a, fp_x, fp_z) and in_footprint(b, fp_x, fp_z) \
        and in_footprint(c, fp_x, fp_z) and in_footprint(d, fp_x, fp_z)
    
    # While the building is not in the footprint...
    while not in_print and rot_mod_count < MAX_MODIFICATIONS:
        # Alternate shrinking the x and z lengths
        if rot_mod_count % 2 == 0:
            len_x -= 1
        else:
            len_z -= 1
        
        # If one of our sides is less than our minimum thinness, then increment
        # by MAX_MODIFICATIONS and break. This will reset the size and rotation
        # of the building.
        if min(len_x, len_z) < MIN_THIN:
            rot_mod_count += MAX_MODIFICATIONS
            break
        
        # Create our new points
        a = Vector2(-len_x / 2, -len_z / 2)
        b = Vector2( len_x / 2,  len_z / 2)
        c = Vector2(-len_x / 2,  len_z / 2)
        d = Vector2( len_x / 2, -len_z / 2)
        
        # Rotate them
        a = a.rotated(deg2rad(rotation))
        b = b.rotated(deg2rad(rotation))
        c = c.rotated(deg2rad(rotation))
        d = d.rotated(deg2rad(rotation))
        
        # Check we're in the footprint
        in_print = in_footprint(a, fp_x, fp_z) and in_footprint(b, fp_x, fp_z) \
        and in_footprint(c, fp_x, fp_z) and in_footprint(d, fp_x, fp_z)
        
        # Increment the modifications we've done
        rot_mod_count += 1
    
    # If we capped out on the number of rolls we allowed, we'll just default to
    # a non-rotated building.
    if rot_mod_count >= MAX_MODIFICATIONS:
        blueprint["rotation"] = 0.0
    
    # Otherwise...
    else:
        # Set the rotation
        blueprint["rotation"] = rotation
        # Update the lengths
        blueprint["len_x"] = len_x
        blueprint["len_z"] = len_z

# This function gets called after make_blueprint, in the construction stage.
# This function wil not be run from a thread; here is where nodes are spawned
# and placed appropriately. However, it's not threaded, so take care and ensure
# the function isn't too complex. The provided building is a TemplateBuilding,
# any modifications should be made to that node. The blueprint dictionary is the
# same one from the make_blueprint function call.
static func make_construction(building : Spatial, blueprint : Dictionary):
    # Get the AutoTower
    var autotower = building.get_node("AutoTower")
    
    # Rotate the AutoTower
    autotower.rotation_degrees.y = blueprint["rotation"]
    
    # Set the building's translation/position
    building.transform.origin = blueprint["origin"]
    
    # Set the building's scale
    building.scale = blueprint["scale"]

# --------------------------------------------------------
#
# Utility/Calculation Functions
#
# --------------------------------------------------------
static func in_footprint(point, footprint_len_x, footprint_len_z):
    if point.x < -footprint_len_x / 2 or footprint_len_x / 2 < point.x:
        return false
    
    if point.y < -footprint_len_z / 2 or footprint_len_z / 2 < point.y:
        return false
    
    return true
