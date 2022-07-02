
const POINT_POSITION_STEP = 2.0

const GROW_POINT = preload("res://grow_points/BuildingGrowPoint.gd")

const MULTIPASS_STEPPER = 3

class GrowBlock:
    
    # A dictionary of all the AABBS (where the GrowAABB is both the key and the
    # value) associated with this block. Keep in mind they may extend beyond the
    # confines of this block. This block is just their parent, for the purposes
    # of managing them.
    var all_aabbs = {}
    # A dicitonary-set of all the AABBs that are still viable, as reported by
    # their is_viable() function.
    var viable_aabbs = {}
    
    func is_viable():
        return not viable_aabbs.empty()

var max_square_size
var x_width
var z_length

var _aabbs_east = []
var _aabbs_west = []
var _aabbs_north = []
var _aabbs_south = []

var _blocks = []

var _block_offset = Vector3.ZERO

# Does a grow-pass on all of the blocks
func grow_all_blocks():
    # For the first three blocks, or however many blocks there are...
    for i in range( min(MULTIPASS_STEPPER, len(_blocks)) ):
        # If this block isn't viable, skip it!!!
        if not _blocks[i].is_viable():
            continue
        
        # This is kinda hard to read, but it goes something like this: the
        # closer a block is to the "front", the more growth we do on it (via
        # calling _grow_block() multiple times). We always grow the block at
        # least once!
        for step in range( max(1, MULTIPASS_STEPPER - i) ):
            _grow_block( _blocks[i] )

func clean_and_spawn_pass():
    var new_blocks = []
    
    for b in _blocks:
        # If this is a viable block, stick it in our new blocks
        if b.is_viable():
            new_blocks.append()
            continue
        # Otherwise... ???
    
    # Assert our new block array over the old one
    _blocks = new_blocks
    
    # While we don't have three blocks...
    while len(_blocks) < 3:
        # SPAWN BLOCKS!
        _spawn_block()

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

    var point_distro = RandomNumberGenerator.new()
    point_distro.randomize()
    
    #
    # Step 1: Seed
    #
    for i in range(40):
        
        redo = true
        
        while redo:
            origin = _block_offset
            
            origin.x += randi() % x_width
            origin.x = stepify(origin.x, POINT_POSITION_STEP)
            
            origin.z += abs(point_distro.randfn(0, z_length * .5))
            origin.z = clamp(origin.z, 0, z_length)
            origin.z = stepify(origin.z, POINT_POSITION_STEP)
            
            redo = origin in points
        
        max_len = max_square_size.interpolate( float(origin.z) / z_length)
        max_len = stepify(max_len, 1.0)
        
        new_aabb = GROW_POINT.GrowAABB.new(origin, max_len, max_len)
        
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
    
    _blocks.append(new_block)
    _block_offset.x += x_width

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
                        print("Blocked East!")
                        break
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
                if grow.b.z >= z_length:
                    grow.south_state = GROW_POINT.SideState.GROW_BLOCKED
            else:
                grow.south_state = result
        
        if grow.west_state == GROW_POINT.SideState.OPEN:
            # Grow to the west
            result = grow.grow_west()
            
            # If there's no problem...
            if result == GROW_POINT.SideState.OPEN:
                # Find our spot in the east array
                index = _aabbs_east.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_east"
                )
                # Get all the points west of our eastern-most point (including
                # ourselves)
                sliced_aabb = _aabbs_east.slice(0, index)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_west()
                        grow.west_state = GROW_POINT.SideState.GROW_BLOCKED
                        break
            else:
                grow.west_state = result
        
        if grow.north_state == GROW_POINT.SideState.OPEN:
            # Grow to the north
            result = grow.grow_north()
            
             # If there's no problem...
            if result == GROW_POINT.SideState.OPEN:
                # Find our spot in the south array
                index = _aabbs_south.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_south"
                )
                # Get all the points north of our southern-most point
                # (including ourselves)
                sliced_aabb = _aabbs_south.slice(0, index)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_north()
                        grow.north_state = GROW_POINT.SideState.GROW_BLOCKED
                        break
                if grow.a.z <= z_length:
                    grow.north_state = GROW_POINT.SideState.GROW_BLOCKED
            else:
                grow.north_state = result
        
        if grow.is_viable():
            new_viables[grow] = grow
    
    block.viable_aabbs = new_viables
