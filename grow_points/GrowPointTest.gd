extends Spatial

const GROW_POINT = preload("res://grow_points/BuildingGrowPoint.gd")
const SECONDARY_NODE = preload("res://grow_points/SecondaryNode.tscn")
onready var dd = get_node("/root/DebugDraw")

const X_WIDTH = 20
const LOWER_Z_LIM = -15#-8
const UPPER_Z_LIM = 15#8

export(Curve) var max_square_size

var aabbs_east = []
var aabbs_west = []
var aabbs_north = []
var aabbs_south = []

var viable_aabbs = []

func _ready():
    # Step 1 Variables
    var origin
    var temp
    var max_len
    var index
    var percent_pos
    
    var points = {}
    var redo = true

    var point_distro = RandomNumberGenerator.new()
    point_distro.randomize()
    
    #
    # Step 1: Seed
    #
    for i in range(30):
        
        redo = true
        
        while redo:
            origin = Vector3.ZERO
            origin.x = (randi() % X_WIDTH) - (X_WIDTH / 2)
            origin.x = stepify(origin.x, 2.0)
            
            origin.z = abs(point_distro.randfn(0, (UPPER_Z_LIM - LOWER_Z_LIM) * .4))
            origin.z = origin.z + LOWER_Z_LIM
            origin.z = clamp(origin.z, LOWER_Z_LIM, UPPER_Z_LIM)
            origin.z = stepify(origin.z, 2.0)
            
            redo = origin in points
        
        temp = SECONDARY_NODE.instance()
        self.add_child(temp)
        temp.translation = origin
        
        max_len = max_square_size.interpolate(
            float(origin.z - LOWER_Z_LIM) / (UPPER_Z_LIM - LOWER_Z_LIM)
        )
        max_len = stepify(max_len, 1.0)
        
        temp = GROW_POINT.GrowAABB.new(origin, max_len, max_len)
        
        points[origin] = temp
        
        self.add_child(temp.mesh)
        
        # Stick our new aabb in each of our sorted arrays, as appropriate.
        index = aabbs_east.bsearch_custom(
            temp, GROW_POINT.GrowAABB, "sort_by_east"
        )
        aabbs_east.insert(index, temp)
        index = aabbs_west.bsearch_custom(
            temp, GROW_POINT.GrowAABB, "sort_by_west"
        )
        aabbs_west.insert(index, temp)
        index = aabbs_north.bsearch_custom(
            temp, GROW_POINT.GrowAABB, "sort_by_north"
        )
        aabbs_north.insert(index, temp)
        index = aabbs_south.bsearch_custom(
            temp, GROW_POINT.GrowAABB, "sort_by_south"
        )
        aabbs_south.insert(index, temp)
        # Stick it in our viables list
        viable_aabbs.append(temp)

    $Timer.start()

func _process(delta):
    for grow in aabbs_east:
        # North
        dd.draw_line_3d(
            grow.a + Vector3(0, 1, 0), 
            Vector3(grow.b.x, grow.a.y, grow.a.z) + Vector3(0, 1, 0),
            Color.white
        )
        # South
        dd.draw_line_3d(
            Vector3(grow.a.x, grow.a.y, grow.b.z) + Vector3(0, 1, 0), 
            grow.b + Vector3(0, 1, 0),
            Color.red
        )
        # East
        dd.draw_line_3d(
            Vector3(grow.b.x, grow.a.y, grow.a.z) + Vector3(0, 1, 0),
            grow.b + Vector3(0, 1, 0),
            Color.blue
        )
        # West
        dd.draw_line_3d(
            grow.a + Vector3(0, 1, 0), 
            Vector3(grow.a.x, grow.a.y, grow.b.z) + Vector3(0, 1, 0),
            Color.yellow
        )

func _on_Timer_timeout():
    var new_viables=[]
    var sliced_aabb
    var result
    var index
    
    #
    # Step 2: Grow
    #
    for grow in viable_aabbs:
        
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
                if grow.b.z >= UPPER_Z_LIM:
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
                if grow.a.z <= LOWER_Z_LIM:
                    grow.north_state = GROW_POINT.SideState.GROW_BLOCKED
            else:
                grow.north_state = result
        
        if grow.is_viable():
            new_viables.append(grow)
    viable_aabbs = new_viables

    if not viable_aabbs.empty():
        $Timer.start()
