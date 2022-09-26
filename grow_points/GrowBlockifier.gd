extends Reference

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

# The city looks organic because we're dynamically growing out the buildings
# and stopping them when they collide with each other. However, since the city
# needs to loop, this creates a problem at the edge where there's no buildings
# to collide with. To get around that, we purposefully grow the more-forward
# blocks more quickly by performing more grow-passes on them. We then step this
# number down as we get farther into the array. So - how many passes do we do on
# the block that's furthest west/left?
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
    
    # This block's assigned number - only really used to help loop the blocks
    var block_number
    
    # Has this block already been cleaned?
    var cleaned = false
    
    # Is this block viable - i.e. can we keep growing the points in the block?
    func is_viable():
        return not viable_aabbs.empty()
    
    # Creates a clone of this block, shifted by the given vector
    func shifted_clone(shift):
        var clone = GrowBlock.new()
        var new_aabb
        
        # Copy the parent block's width & length
        clone.x_width = self.x_width
        clone.z_length = self.z_length
        
        # Copy the parent block's origin, but shifted
        clone.block_origin = self.block_origin + shift
        
        # For each of the old/source block's AABBs... 
        for old_aabb in all_aabbs:
            # Create a new AABB, shifted appropriately
            new_aabb = GROW_POINT.GrowAABB.new(
                old_aabb.origin + shift,
                old_aabb.max_x_len, old_aabb.max_z_len,
                old_aabb.height
            )
            # Copy the A and B, shifted appropriately
            new_aabb.a = old_aabb.a + shift
            new_aabb.b = old_aabb.b + shift
            
            # Copy the side states
            new_aabb.east_state = old_aabb.east_state
            new_aabb.south_state = old_aabb.south_state
            new_aabb.north_state = old_aabb.north_state
            new_aabb.west_state = old_aabb.west_state
            
            # Copy clean status
            clone.cleaned = self.cleaned
            
            # Stick the new AABB in the clone's aabb set
            clone.all_aabbs[new_aabb] = new_aabb
            
            # If this source aabb is still viable, stick it in the clone's
            # viable AABB set.
            if old_aabb in self.viable_aabbs:
                clone.viable_aabbs[new_aabb] = new_aabb
        
        # Done cloning!
        return clone

# How many blocks do we generate?
var target_blocks = 50

var _cleaned_blocks = 0

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
func spawn_step():
    # While we don't have TARGET_BLOCK_COUNT blocks...
    while len(_blocks) < target_blocks:
        # SPAWN BLOCKS!
        _spawn_block()

# Does a grow-pass on all of the blocks (if any of the blocks are viable)
func grow_pass():
    # How many "grow passes" are we going to do on an individual block?
    var pass_count = MULTIPASS_START_VALUE
    
    # For all of our blocks...
    for i in range( len(_blocks) ):
        # If this block isn't viable, skip it!!!
        if not _blocks[i].is_viable():
            continue
        
        # Grow the block according to our current pass count.
        for step in range( pass_count ):
            _grow_block( _blocks[i] )
        
        # Decrement the number of passes we'll do for the next block
        pass_count -= 1
        
        # If we're under our target passes, do nothing.
        if pass_count <= 0:
            break

# Cleans up the blocks that we don't need anymore.
func clean_pass():
    var shift
    var clone_block
    var index
    
    for b in _blocks:
        # If this block has already been cleaned, skip it!
        if b.cleaned:
            continue
        # Otherwise, if this is a viable block, we can't clean it yet
        elif b.is_viable():
            continue
        # Otherwise, this block isn't viable. However, if we don't have a
        # neighbor, or our neighbor is still viable, we'll want to keep it.
        # We'll want to keep this if we don't have a neighbor because that
        # indicates the next spawn will be NEXT TO US.
        elif b.right_neighbor == null or b.right_neighbor.is_viable():
            continue
        
        # If we're here, then this block AND it's neighbor isn't viable, so we
        # don't need to track it anymore!
        _clean_block(b)
        
        # Increment the number of blocks we've cleaned
        _cleaned_blocks += 1
        
        # If we're cleaning Block #0, then we need to clone and append it to the
        # end of the blocks to create the effect of a loop.
        if b.block_number == 0:
            shift = len(_blocks) * (x_width + INTRA_BLOCK_SPACER)
            clone_block = b.shifted_clone( Vector3(shift, 0, 0) )
            _insert_block(clone_block)
        
func has_viable_blocks():
    for b in _blocks:
        if b.is_viable():
            return true
    return false

func requires_more_passes():
    # We require more passes (grow, clean, etc) if we have don't have any more
    # blocks to clean.
    return target_blocks - _cleaned_blocks <= 0

func _insert_block(block):
    var index
    
    # Stick each AABB in the sorted arrays, as appropriate.
    for aabb in block.all_aabbs:
        index = _aabbs_east.bsearch_custom(
            aabb, GROW_POINT.GrowAABB, "sort_by_east"
        )
        _aabbs_east.insert(index, aabb)
        
        index = _aabbs_west.bsearch_custom(
            aabb, GROW_POINT.GrowAABB, "sort_by_west"
        )
        _aabbs_west.insert(index, aabb)
        
        index = _aabbs_north.bsearch_custom(
            aabb, GROW_POINT.GrowAABB, "sort_by_north"
        )
        _aabbs_north.insert(index, aabb)
        
        index = _aabbs_south.bsearch_custom(
            aabb, GROW_POINT.GrowAABB, "sort_by_south"
        )
        _aabbs_south.insert(index, aabb)
    
    # If we have extra blocks, make sure the LAST block knows that this new
    # block is it's neighbor.
    if not _blocks.empty():
        _blocks[-1].right_neighbor = block
    
    # Set the block number
    block.block_number = len(_blocks)
    
    # Append the block
    _blocks.append(block)
    
    # Since this block has just been inserted into the sorted aabbs, we'll say
    # it hasn't been cleaned yet.
    block.cleaned = false

func _spawn_block():
    # Step 1 Variables
    var origin
    var max_len
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
            
            # HACK: Somehow, x_width was a float here (despite being set to an
            # int???). Not sure what's going on here.
            origin.x += randi() % int(x_width)
            origin.x = stepify(origin.x, POINT_POSITION_STEP)
            
            origin.z += abs(point_distro.randfn(0, z_length * .4))
            origin.z = clamp(origin.z, 0, z_length)
            origin.z = stepify(origin.z, POINT_POSITION_STEP)
            
            redo = origin in points
            break
        
        max_len = max_square_size.interpolate( float(origin.z) / z_length)
        max_len = stepify(max_len, 1.0)
        
        min_height_val = min_height.interpolate( float(origin.z) / z_length)
        max_height_val = max_height.interpolate( float(origin.z) / z_length)
        
        height = randf() * (max_height_val - min_height_val) + min_height_val
        height = int( stepify(height, 1.0) )
        
        new_aabb = GROW_POINT.GrowAABB.new(origin, max_len, max_len, height)
        
        points[origin] = new_aabb
        
        # Stick it in our viables list
        new_block.all_aabbs[new_aabb] = new_aabb
        new_block.viable_aabbs[new_aabb] = new_aabb

    # Insert the new block
    _insert_block(new_block)

    # Update the offset
    _block_offset.x += x_width + INTRA_BLOCK_SPACER

func _grow_block( block ):
    var new_viables={}
    var sliced_aabb
    var result
    var index
    
    var target
    
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
                # Get our upper target - we don't want to go through the whole
                # sorted array, but we do want to go through at least one
                # block's worth.
                target = min(index + points_per_block, len(_aabbs_west) - 1)
                # Get all the points east of our western-most point
                sliced_aabb = _aabbs_west.slice(index, target)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_east()
                        grow.east_state = GROW_POINT.SideState.GROW_BLOCKED
                        break
                
                # Find our spot in the east array
                index = _aabbs_east.find(grow)
                # Pull it out
                _aabbs_east.remove(index)
                # Find where we should go in the east array
                index = _aabbs_east.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_east", true
                )
                # Stick it back in
                _aabbs_east.insert(index, grow)
                
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
                # Get our upper target - we don't want to go through the whole
                # sorted array, but we do want to go through at least one
                # block's worth.
                target = min(index + points_per_block, len(_aabbs_north) - 1)
                # Get all the points south of our northern-most point
                sliced_aabb = _aabbs_north.slice(index, len(_aabbs_north) - 1)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_south()
                        grow.south_state = GROW_POINT.SideState.GROW_BLOCKED
                        break
                
                # Find our spot in the south array
                index = _aabbs_south.find(grow)
                # Pull it out
                _aabbs_south.remove(index)
                # Find where we should go in the south array
                index = _aabbs_south.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_south", true
                )
                # Stick it back in
                _aabbs_south.insert(index, grow) 
                
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
                # Get our lower target - we don't want to go through the whole
                # sorted array, but we do want to go through at least one
                # block's worth.
                target = max(index - points_per_block, 0)
                # Get all the points west of our eastern-most point (including
                # ourselves)
                sliced_aabb = _aabbs_east.slice(target, index)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_west()
                        grow.west_state = GROW_POINT.SideState.GROW_BLOCKED
                        break
                
                # Find our spot in the west array
                index = _aabbs_west.find(grow)
                # Pull it out
                _aabbs_west.remove(index)
                # Find where we should go in the west array
                index = _aabbs_west.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_west", true
                )
                # Stick it back in
                _aabbs_west.insert(index, grow)      
                
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
                # Get our lower target - we don't want to go through the whole
                # sorted array, but we do want to go through at least one
                # block's worth.
                target = max(index - points_per_block, 0)
                # Get all the points north of our southern-most point
                # (including ourselves)
                sliced_aabb = _aabbs_south.slice(target, index)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_north()
                        grow.north_state = GROW_POINT.SideState.GROW_BLOCKED
                        break
                
                # Find our spot in the north array
                index = _aabbs_north.find(grow)
                # Pull it out
                _aabbs_north.remove(index)
                # Find where we should go in the north array
                index = _aabbs_north.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_north", true
                )
                # Stick it back in
                _aabbs_north.insert(index, grow)
                
            else:
                grow.north_state = result
        
        if grow.is_viable():
            new_viables[grow] = grow
    
    block.viable_aabbs = new_viables

func _clean_block( block, add_to_complete=true):
    # For each aabb in this block...
    for aabb in block.all_aabbs:
        # Delete it from our sorting arrays. The bsearch_custom function was
        # returning odd values, so we're going to use the slow-style erase
        # function.
        _aabbs_east.erase(aabb)
        _aabbs_west.erase(aabb)
        _aabbs_north.erase(aabb)
        _aabbs_south.erase(aabb)
        
        # If we're trying to add the AABBs to complete set, stick this aabb in
        # our completed array!
        if add_to_complete:
            _complete_aabbs.append(aabb)
    
    # Ensure the block knows that it's cleaned
    block.cleaned = true
