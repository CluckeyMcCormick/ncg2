
# Including this scene so we can spawn GrowPoint objects.
const GROW_POINT = preload("res://grow_points/BuildingGrowPoint.gd")

# To help ensure the buildings are all aligned on the same grid, we'll snap the
# origin points to specific steps of a certain value - i.e. multiples of 1,
# multiples of 2, multiples of 3, etc. This has the added advantage of
# guaranteeing a minimum size by spacing the points out, allowing them to grow.
# So, what is the step (i.e. multiple) that we snap points to?
const POINT_POSITION_STEP = 2.0

# How much of a gap is there between two blocks? There needs to be at least some
# space, because otherwise the points-on-the-edge may spawn on top of each
# other.
const INTRA_BLOCK_SPACER = POINT_POSITION_STEP * 2

# How many blocks do we aim to consistently have?
const TARGET_BLOCK_COUNT = 6

# The city looks organic because we're dynamically growing out the buildings
# and stopping them when they collide with each other. However, since the city
# is infinite, this creates a problem at the edge where there's no buildings to
# collide with. To get around that, we purposefully grow the more-forward blocks
# more quickly by performing more grow-passes on them. We then step this number
# down as we get farther into the array. So - how many passes do we do on the
# block that's furthest west/left?
const MULTIPASS_START_VALUE = 3

class GrowBlock:
    
    # A dictionary of all the AABBS (where the GrowAABB is both the key and the
    # value) associated with this block. Keep in mind they may extend beyond the
    # confines of this block. This block is just their parent, for the purposes
    # of managing them.
    var all_aabbs = {}
    # A dicitonary-set of all the AABBs that are still viable, as reported by
    # their is_viable() function.
    var viable_aabbs = {}
    
    # The block's right/east/+x neighbor.
    var right_neighbor = null
    
    # The block's origin - not necessarily the middle, but where we started
    # seeding points for this block from. Technically, this should be the point
    # in the block closest to (-INF, 0, -INF).
    var block_origin = Vector3.ZERO
    # The x_width and z_length used to generate this block.
    var x_width
    var z_length
    
    func is_viable():
        return not viable_aabbs.empty()

var max_square_size
var min_height = null
var max_height = null
var x_width
var z_length
var points_per_block

var _aabbs_east = []
var _aabbs_west = []
var _aabbs_north = []
var _aabbs_south = []

var _blocks = []
var _complete_aabbs = []

var _block_offset = Vector3.ZERO

func _init(size_curve, min_height, max_height, x_width, z_length, points_per_block):
    self.max_square_size = size_curve
    self.min_height = min_height
    self.max_height = max_height
    self.points_per_block = points_per_block
    self.x_width = x_width
    self.z_length = z_length

# Spawns in new blocks - if we have space for them
func spawn_pass():
    # While we don't have TARGET_BLOCK_COUNT blocks...
    while len(_blocks) < TARGET_BLOCK_COUNT:
        # SPAWN BLOCKS!
        _spawn_block()

# Does a grow-pass on all of the blocks (if any of the blocks are viable)
func grow_pass():
    # How many "grow passes" are we going to do on an individual block?
    var pass_count = MULTIPASS_START_VALUE
    
    # For the first three blocks, or however many blocks there are...
    for i in range( min(TARGET_BLOCK_COUNT, len(_blocks)) ):
        # If this block isn't viable, skip it!!!
        if not _blocks[i].is_viable():
            continue
        
        # Grow the block according to our current pass count.
        for step in range( pass_count ):
            _grow_block( _blocks[i] )
        
        # Decrement the number of passes we'll do for the next block, down to a
        # minimum of one pass
        pass_count = max(1, pass_count - 1)

# Cleans up the blocks that we don't need anymore.
func clean_pass():
    var new_blocks = []
    
    for b in _blocks:
        # If this is a viable block, stick it in our new blocks
        if b.is_viable():
            new_blocks.append(b)
            continue
        # Otherwise, this block isn't viable. However, if we don't have a
        # neighbor, or our neighbor is still viable, we'll want to keep it.
        # We'll want to keep this if we don't have a neighbor because that
        # indicates the next spawn will be NEXT TO US.
        elif b.right_neighbor == null or b.right_neighbor.is_viable():
            new_blocks.append(b)
            continue
        
        # If we're here, then this block AND it's neighbor isn't viable,
        # so we don't need to track it anymore!
        _clean_block(b)
    
    # Assert our new block array over the old one
    _blocks = new_blocks

func has_viable_blocks():
    for b in _blocks:
        if b.is_viable():
            return true
    return false

func _spawn_block():
    # Step 1 Variables
    var origin
    var max_len
    var index
    var percent_pos
    
    var points = {}
    var redo = true

    var new_aabb
    var new_block = GrowBlock.new()

    var min_height_val
    var max_height_val
    var height

    var point_distro = RandomNumberGenerator.new()
    point_distro.randomize()
    
    # Set the block's generation data
    new_block.block_origin = _block_offset
    new_block.x_width = x_width
    new_block.z_length = z_length
    
    #
    # Step 1: Seed
    #
    for i in range(points_per_block):
        
        redo = true
        
        while redo:
            origin = _block_offset
            
            origin.x += randi() % x_width
            origin.x = stepify(origin.x, POINT_POSITION_STEP)
            
            origin.z += abs(point_distro.randfn(0, z_length * .4))
            origin.z = clamp(origin.z, 0, z_length)
            origin.z = stepify(origin.z, POINT_POSITION_STEP)
            
            redo = origin in points
        
        max_len = max_square_size.interpolate( float(origin.z) / z_length)
        max_len = stepify(max_len, 1.0)
        
        min_height_val = min_height.interpolate( float(origin.z) / z_length)
        max_height_val = max_height.interpolate( float(origin.z) / z_length)
        
        height = randf() * (max_height_val - min_height_val) + min_height_val
        height = int( stepify(height, 1.0) )
        
        new_aabb = GROW_POINT.GrowAABB.new(origin, max_len, max_len, height)
        
        points[origin] = new_aabb
        
        # Stick our new aabb in each of our sorted arrays, as appropriate.
        index = _aabbs_east.bsearch_custom(
            new_aabb, GROW_POINT.GrowAABB, "sort_by_east"
        )
        _aabbs_east.insert(index, new_aabb)
        
        index = _aabbs_west.bsearch_custom(
            new_aabb, GROW_POINT.GrowAABB, "sort_by_west"
        )
        _aabbs_west.insert(index, new_aabb)
        
        index = _aabbs_north.bsearch_custom(
            new_aabb, GROW_POINT.GrowAABB, "sort_by_north"
        )
        _aabbs_north.insert(index, new_aabb)
        
        index = _aabbs_south.bsearch_custom(
            new_aabb, GROW_POINT.GrowAABB, "sort_by_south"
        )
        _aabbs_south.insert(index, new_aabb)
        
        # Stick it in our viables list
        new_block.all_aabbs[new_aabb] = new_aabb
        new_block.viable_aabbs[new_aabb] = new_aabb
    
    # If we have extra blocks, make sure the LAST block knows that this new
    # block is it's neighbor.
    if not _blocks.empty():
        _blocks[-1].right_neighbor = new_block
    
    _blocks.append(new_block)
    _block_offset.x += x_width + INTRA_BLOCK_SPACER

func _grow_block( block ):
    var new_viables={}
    var sliced_aabb
    var result
    var index
    
    #
    # Step 2: Grow
    #
    for grow in block.viable_aabbs:
        
        # Grow on each viable direction. Everytime we grow, check all the
        # appropriate AABBs to ensure no collision, or crossing world
        # boundaries.
        
        if grow.east_state == GROW_POINT.SideState.OPEN:
            # Grow to the east
            result = grow.grow_east()
            
            # If there's no problem...
            if result == GROW_POINT.SideState.OPEN:
                # Find our spot in the west array
                index = _aabbs_west.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_west"
                )
                # Get all the points east of our western-most point
                sliced_aabb = _aabbs_west.slice(index, len(_aabbs_west) - 1)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_east()
                        grow.east_state = GROW_POINT.SideState.GROW_BLOCKED
                        break
                
                # Re-sort to reflect the new eastern size of this AABB.
                _aabbs_east.sort_custom(GROW_POINT.GrowAABB, "sort_by_east") 
            else:
                grow.east_state = result
        
        if grow.south_state == GROW_POINT.SideState.OPEN:
            # Grow to the south
            result = grow.grow_south()
            
            # If there's no problem...
            if result == GROW_POINT.SideState.OPEN:
                # Find our spot in the north array
                index = _aabbs_north.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_north"
                )
                # Get all the points south of our northern-most point
                sliced_aabb = _aabbs_north.slice(index, len(_aabbs_north) - 1)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_south()
                        grow.south_state = GROW_POINT.SideState.GROW_BLOCKED
                        break
                
                # Re-sort to reflect the new southern size of this AABB.
                _aabbs_south.sort_custom(GROW_POINT.GrowAABB, "sort_by_south") 
            else:
                grow.south_state = result
        
        if grow.west_state == GROW_POINT.SideState.OPEN:
            # Grow to the west
            result = grow.grow_west()
            
            # If there's no problem...
            if result == GROW_POINT.SideState.OPEN:
                # Find our spot in the east array
                index = _aabbs_east.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_east", true
                )
                # Get all the points west of our eastern-most point (including
                # ourselves)
                sliced_aabb = _aabbs_east.slice(0, index)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_west()
                        grow.west_state = GROW_POINT.SideState.GROW_BLOCKED
                        break
                
                # Re-sort to reflect the new western size of this AABB.
                _aabbs_west.sort_custom(GROW_POINT.GrowAABB, "sort_by_west")        
                
            else:
                grow.west_state = result
        
        if grow.north_state == GROW_POINT.SideState.OPEN:
            # Grow to the north
            result = grow.grow_north()
            
             # If there's no problem...
            if result == GROW_POINT.SideState.OPEN:
                # Find our spot in the south array
                index = _aabbs_south.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_south", true
                )
                # Get all the points north of our southern-most point
                # (including ourselves)
                sliced_aabb = _aabbs_south.slice(0, index)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_north()
                        grow.north_state = GROW_POINT.SideState.GROW_BLOCKED
                        break
                
                # Re-sort to reflect the new northern size of this AABB.
                _aabbs_north.sort_custom(GROW_POINT.GrowAABB, "sort_by_north")
            else:
                grow.north_state = result
        
        if grow.is_viable():
            new_viables[grow] = grow
    
    block.viable_aabbs = new_viables

func _clean_block( block ):
    # For each aabb in this block...
    for aabb in block.all_aabbs:
        # Delete it from our sorting arrays. The bsearch_custom function was
        # returning odd values, so we're going to use the slow-style erase
        # function.
        _aabbs_east.erase(aabb)
        _aabbs_west.erase(aabb)
        _aabbs_north.erase(aabb)
        _aabbs_south.erase(aabb)
        
        # Stick this aabb in our completed array!
        _complete_aabbs.append(aabb)
    
    # Clear out our environment variables so we don't have any dangling
    # references.
    block.all_aabbs.clear()
    block.viable_aabbs.clear()
    block.right_neighbor = null
