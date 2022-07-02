
const POINT_POSITION_STEP = 2.0

const GROW_POINT = preload("res://grow_points/BuildingGrowPoint.gd")

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

var aabbs_east = []
var aabbs_west = []
var aabbs_north = []
var aabbs_south = []

var blocks = []

func spawn_block():
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
    for i in range(30):
        
        redo = true
        
        while redo:
            origin = Vector3.ZERO
            origin.x = randi() % x_width
            origin.x = stepify(origin.x, POINT_POSITION_STEP)
            
            origin.z = abs(point_distro.randfn(0, z_length * .5))
            origin.z = clamp(origin.z, 0, z_length)
            origin.z = stepify(origin.z, POINT_POSITION_STEP)
            
            redo = origin in points
        
        max_len = max_square_size.interpolate( float(origin.z) / z_length)
        max_len = stepify(max_len, 1.0)
        
        new_aabb = GROW_POINT.GrowAABB.new(origin, max_len, max_len)
        
        points[origin] = new_aabb
        
        # Stick our new aabb in each of our sorted arrays, as appropriate.
        index = aabbs_east.bsearch_custom(
            new_aabb, GROW_POINT.GrowAABB, "sort_by_east"
        )
        aabbs_east.insert(index, new_aabb)
        index = aabbs_west.bsearch_custom(
            new_aabb, GROW_POINT.GrowAABB, "sort_by_west"
        )
        aabbs_west.insert(index, new_aabb)
        index = aabbs_north.bsearch_custom(
            new_aabb, GROW_POINT.GrowAABB, "sort_by_north"
        )
        aabbs_north.insert(index, new_aabb)
        index = aabbs_south.bsearch_custom(
            new_aabb, GROW_POINT.GrowAABB, "sort_by_south"
        )
        aabbs_south.insert(index, new_aabb)
        # Stick it in our viables list
        new_block.all_aabbs[new_aabb] = new_aabb
        new_block.viable_aabbs[new_aabb] = new_aabb
    
    blocks.append(new_block)

func grow_block( block ):
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
                index = aabbs_west.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_west"
                )
                # Get all the points east of our western-most point
                sliced_aabb = aabbs_west.slice(index, len(aabbs_west) - 1)
                
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
                index = aabbs_north.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_north"
                )
                # Get all the points south of our northern-most point
                sliced_aabb = aabbs_north.slice(index, len(aabbs_north) - 1)
                
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
                index = aabbs_east.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_east"
                )
                # Get all the points west of our eastern-most point (including
                # ourselves)
                sliced_aabb = aabbs_east.slice(0, index)
                
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
                index = aabbs_south.bsearch_custom(
                    grow, GROW_POINT.GrowAABB, "sort_by_south"
                )
                # Get all the points north of our southern-most point
                # (including ourselves)
                sliced_aabb = aabbs_south.slice(0, index)
                
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
