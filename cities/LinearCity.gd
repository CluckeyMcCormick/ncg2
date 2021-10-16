extends Spatial

# Preload the Facsimilie Block 
const FACSIMILIE_BLOCK = preload("res://blocks/FacsimilieBlock.tscn")

# What's the group name we'll provide to the facsimilie blocks - so we know when
# any block enters or exits the screen?
const CITY_GROUP_NAME = "LinearCity"

# What's the name we use for blocks in this specific city?
const CITY_BLOCKS_NAME = "LinearCityBlocks"

# The block cache we'll use to set the buildings/meshes of our various
# Facsimilie Blocks. This needs to be set via code.
var block_cache

# When we spawn in new blocks, we try to ensure they appear in the camera's
# viewpoint. In order to do the painful math involved in that nonsense, we need
# to know how the camera is rotated. This exists entirely externally, so this
# value NEEDS to be set by some external code source.
var camera_vector

# By how much additional.... units do we seperate rows?
var row_seperation_additive = 1
# How many rows do we have?
var row_count = 3
#
var seed_distance = 10

# Called when the node enters the scene tree for the first time.
func _ready():
    
    for i in range(row_count):
        _plant_row_seed_block(i)
    
    # Assert that we actually got a block cache. This will only catch it for
    # debug builds but that SHOULD be enough.
    assert(not block_cache == null)

func _plant_row_seed_block(row_index):
    # Create a "seed block" from which all the other blocks will flow
    var seed_block = FACSIMILIE_BLOCK.instance()
    
    # Give it our first group! We'll just assume that's what we'll need. Yeah,
    # that probably won't backfire.
    seed_block.parent_city_group = CITY_GROUP_NAME
    
    # Set the group for the block
    seed_block.add_to_group(CITY_BLOCKS_NAME)
    
    # Set it's position
    seed_block.translation = _calculate_row_start_position(row_index)
    
    # STICK IT!
    self.add_child(seed_block)

# Each row of blocks in the LinearCity is aligned on an axis in the negative z
# space, parallel to the x axis. Each one of these axes has a mathematically
# calculated position in z-space. This function IS that math formula. It
# calculates the distance (length on z) between the origin x axis and the given
# row's axis.
func _calculate_row_axis_distance(row_index):
    # We start at the seed distance
    var distance = seed_distance
    # Each row is seperated by the block lengths - 1 length per index.
    distance += row_index * block_cache.BLOCK_SIDE_LENGTH
    # Each row is ALSO seperated by the row seperation additive 
    distance += row_index * row_seperation_additive
    # Okay, that's it! Return that distance!
    return distance

# As stated above, each row basically exists as a parallel axis of x. However,
# while we may know where the axis lies, we need to "start" the row by planting
# a seed block on the axis at a point that is on camera. That's where this 
# function comes in - given a row starting position, it calculates where to
# place the seed block so it IDEALLY appears on screen.
func _calculate_row_start_position(row_index):
    # Okay, so rows need to start on camera. First, let's find out how far away
    # the given axis SHOULD be.
    var axis_distance = _calculate_row_axis_distance(row_index)
    # Next, let's get the angle of the camera. Make sure it's absolute to a
    # negative value doesn't mess with our calculations
    var camera_angle = abs(camera_vector.angle_to(Vector3.FORWARD))
    # Alright, now summoning the demons of high school geometry: we know the
    # angle between a straight-forward line and the camera axis line. We know
    # the distance to the axis line. Now we need to know the length of the
    # camera axis line. In other words, we know an angle & an adjacent side, and
    # we want to know the hypotenuse. After some basic high school math, we can
    # calculate this using [hypotenuse = axis_distance/cos(camera_angle)]. SO:
    var camera_aligned_distance = axis_distance/cos(camera_angle)
    
    # Scaling the camera vector by our camera-aligned-distance gives us the
    # start position. HOORAY!
    return camera_vector * camera_aligned_distance

func _on_any_block_enter_screen(facsimilie_block):
    # First, give the requesting block a Qodot mesh
    var chosen_map = block_cache.get_random_map()
    facsimilie_block.copy_qodot_block(block_cache.map_to_node[chosen_map])
    
    # Next, if we don't have a left block, make one of those.
    if facsimilie_block.left_neighbor == null:
        # Create the left block
        var left_block = FACSIMILIE_BLOCK.instance()
        
        # Neighborize the two blocks
        facsimilie_block.left_neighbor = left_block
        left_block.right_neighbor = facsimilie_block
        
        # Adjust the translation of the left block
        left_block.translation = Vector3.LEFT * block_cache.BLOCK_SIDE_LENGTH
        left_block.translation += facsimilie_block.translation
        
        # Give it the parent group
        left_block.parent_city_group = CITY_GROUP_NAME
        
        # Set the group for the block
        left_block.add_to_group(CITY_BLOCKS_NAME)
        
        # STICK IT!
        self.add_child(left_block)
    
    #If we don't have a right block, make one of those.
    if facsimilie_block.right_neighbor == null:
        # Create the left block
        var right_block = FACSIMILIE_BLOCK.instance()
        
        # Neighborize the two blocks
        facsimilie_block.right_neighbor = right_block
        right_block.left_neighbor = facsimilie_block
        
        # Adjust the translation of the right block
        right_block.translation = Vector3.RIGHT * block_cache.BLOCK_SIDE_LENGTH
        right_block.translation += facsimilie_block.translation
        
        # Give it the parent group
        right_block.parent_city_group = CITY_GROUP_NAME

        # Set the group for the block
        right_block.add_to_group(CITY_BLOCKS_NAME)
        
        # STICK IT!
        self.add_child(right_block)

func _on_any_block_exit_screen(facsimilie_block):
    # First, get the left & right neighbor blocks in some shorthand variables
    var left = facsimilie_block.left_neighbor
    var right = facsimilie_block.right_neighbor
    
    # Secondly, wrap the neighbors in weak references 
    var weak_left = weakref(left)
    var weak_right = weakref(right)
    
    # If we have a left neighbor, and the left neighbor is not visible, then
    # free the neighbor.
    if weak_left.get_ref() and not left.is_effectively_visibile():
        left.queue_free()
        facsimilie_block.left_neighbor = null

    # If we have a right neighbor, and the right neighbor is not visible, then
    # free the neighbor.
    if weak_right.get_ref() and not right.is_effectively_visibile():
        right.queue_free()
        facsimilie_block.right_neighbor = null
    
    # If we don't have a left neighbor or a right neighbor, then we're an
    # orphan. Let's free ourselves!
    if (not weak_left.get_ref()) and (not weak_right.get_ref()):
        facsimilie_block.queue_free()
