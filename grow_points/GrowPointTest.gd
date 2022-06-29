extends Spatial

const SECONDARY_NODE = preload("res://grow_points/SecondaryNode.tscn")

const MATERIALS = [
    preload("res://voronoi/VoroniColorA.material"),
    preload("res://voronoi/VoroniColorB.material"),
    preload("res://voronoi/VoroniColorC.material"),
    preload("res://voronoi/VoroniColorD.material"),
    preload("res://voronoi/VoroniColorE.material"),
    preload("res://voronoi/VoroniColorF.material"),
    preload("res://voronoi/VoroniColorG.material"),
    preload("res://voronoi/VoroniColorH.material"),
    preload("res://voronoi/VoroniColorI.material"),
    preload("res://voronoi/VoroniColorJ.material"),
]

const X_WIDTH = 30
const LOWER_Z_LIM = -15#-8
const UPPER_Z_LIM = 15#8

const MIN_X = 3
const MAX_X = X_WIDTH / 2
const MIN_Z = 3
const MAX_Z = (UPPER_Z_LIM - LOWER_Z_LIM) / 2

onready var dd = get_node("/root/DebugDraw")

enum SideState {OPEN=0, GROW_BLOCKED=11, LENGTH_MAXED=222,}

class GrowAABB:
    
    # The position (vector) closer to negative infinity on X and Z. This is the
    # North-West point.
    var a
    # The position (vector) farther from negative infinity on X and Z. This is
    # the South-East point.
    var b
    # The origin that we grew out from.
    var origin
    
    #
    var max_x_len
    var max_z_len
    
    var east_state = SideState.OPEN
    var south_state = SideState.OPEN
    var north_state = SideState.OPEN
    var west_state = SideState.OPEN
    
    var mesh = null
    
    static func sort_by_east(one, two):
        return one.b.x < two.b.x
    
    static func sort_by_south(one, two):
        return one.b.z < two.b.z
        
    static func sort_by_west(one, two):
        return one.a.x < two.a.x
    
    static func sort_by_north(one, two):
        return one.a.z < two.a.z

    func _init(in_origin, in_max_x_len, in_max_z_len):
        origin = in_origin
        
        a = origin
        b = origin
        
        max_x_len = in_max_x_len
        max_z_len = in_max_z_len
        
        mesh = MeshInstance.new()
        mesh.translation = (a + b) / 2
        mesh.mesh = PlaneMesh.new()
        mesh.mesh.size = Vector2( b.x - a.x, b.z - a.z )
        mesh.set_surface_material(
            0, MATERIALS[ randi() % len(MATERIALS)]
        )
    
    # According to documentation, Godot's global east is given by Vector3.RIGHT,
    # which is equivalent to (1, 0, 0)
    func shrink_east(scalar=1):
        return grow_east(scalar * -1)
    func grow_east(scalar=1):
        var ret = SideState.OPEN
        
        # Grow easterly.
        b.x += scalar
        # If we've somehow gone beyond origin, reset.
        if b.x < origin.x:
            b.x = origin.x
        # If we over the maximum x length..
        if b.x - a.x > max_x_len:
            # Shrink this side by the appropriate amount.
            b.x -= (b.x - a.x) - max_x_len
            # Return that we maxed on this side
            ret = SideState.LENGTH_MAXED
        # Update the mesh
        mesh.translation = (a + b) / 2
        mesh.mesh.size = Vector2( b.x - a.x, b.z - a.z )
        
        return ret

    # According to documentation, Godot's global south is given by
    # Vector3.FORWARD, which is equivalent to (0, 0, 1)
    func shrink_south(scalar=1):
        grow_south(scalar * -1)
    func grow_south(scalar=1):
        var ret = SideState.OPEN
        
        # Grow southerly.
        b.z += scalar
        # If we've somehow gone beyond origin, reset.
        if b.z < origin.z:
            b.z = origin.z
        # If we over the maximum z length...
        if b.z - a.z > max_z_len:
            # Shrink this side by the appropriate amount.
            b.z -= (b.z - a.z) - max_z_len
            # Return that we maxed on this side
            ret = SideState.LENGTH_MAXED
        # Update the mesh
        mesh.translation = (a + b) / 2
        mesh.mesh.size = Vector2( b.x - a.x, b.z - a.z )
        
        return ret

    # According to documentation, Godot's global west is given by Vector3.LEFT,
    # which is equivalent to (-1, 0, 0)
    func shrink_west(scalar=1):
        return grow_west(scalar * -1)
    func grow_west(scalar=1):
        var ret = SideState.OPEN
        
        # Grow easterly.
        a.x -= scalar
        # If we've somehow gone beyond origin, reset.
        if a.x > origin.x:
            a.x = origin.x
        # If we over the maximum x length...
        if b.x - a.x > max_x_len:
            # Shrink this side by the appropriate amount.
            a.x += (b.x - a.x) - max_x_len
            # Return that we maxed on this side
            ret = SideState.LENGTH_MAXED
        # Update the mesh
        mesh.translation = (a + b) / 2
        mesh.mesh.size = Vector2( b.x - a.x, b.z - a.z )
        
        return ret
    
    # According to documentation, Godot's global north is given by
    # Vector3.FORWARD, which is equivalent to (0, 0, -1)
    func shrink_north(scalar=1):
        return grow_north(scalar * -1)
    func grow_north(scalar=1):
        var ret = SideState.OPEN
        
        # Grow northerly.
        a.z -= scalar
        # If we've somehow gone beyond origin, reset.
        if a.z > origin.z:
            a.z = origin.z
        # If we over the maximum z length...
        if b.z - a.z > max_z_len:
            # Shrink this side by the appropriate amount.
            a.z += (b.z - a.z) - max_z_len
            # Return that we maxed on this side
            ret = SideState.LENGTH_MAXED
        # Update the mesh
        mesh.translation = (a + b) / 2
        mesh.mesh.size = Vector2( b.x - a.x, b.z - a.z )
        
        return ret
    
    # Reports if this connection's projected AABB collides with the projected
    # AABB of a different connection. 
    func collides_with(other):
        # We'll package the other's a & b points as e & f, for easy reference
        # and increased sanity.
        var e = other.a
        var f = other.b
        
        # We now need to test if either e or f somehow fall between a and b.
        # We'll test x and z individually.
        
        # [x1, y1, x2, y2], ergo
        # rec1[0] = a.x     rec2[0] = e.x
        # rec1[1] = a.z     rec2[1] = e.z
        # rec1[2] = b.x     rec2[2] = f.x
        # rec1[3] = b.z     rec2[3] = f.z
        
        var width_overlap = min(b.x, f.x) > max(a.x, e.x)
        var height_overlap = min(b.z, f.z) > max(a.z, e.z)
        
        return width_overlap and height_overlap
    
    # Is this grow AABB viable - can it still grow in at least one direction?
    func is_viable():
        return east_state == SideState.OPEN or south_state == SideState.OPEN \
            or west_state == SideState.OPEN or north_state == SideState.OPEN

export(Curve) var spawn_weights
export(Curve) var spawn_chance
export(float) var none_weight
var weight_bag = null

var aabbs_east = []
var aabbs_west = []
var aabbs_north = []
var aabbs_south = []

var viable_aabbs = []

func _ready():
    # Step 1 Variables
    var origin
    var max_x
    var max_z
    var temp
    var index
    
    randomize()
    
    #
    # Step 1: Seed
    #
    for i in range(15):
        origin = Vector3.ZERO
        origin.x = (randi() % X_WIDTH) - (X_WIDTH / 2) 
        origin.z = (randi() % (UPPER_Z_LIM - LOWER_Z_LIM)) + LOWER_Z_LIM
        
        temp = SECONDARY_NODE.instance()
        self.add_child(temp)
        temp.translation = origin
    
        max_x = (randi() % (MAX_X - MIN_X)) + MIN_X
        max_z = (randi() % (MAX_Z - MIN_Z)) + MIN_Z
        
        temp = GrowAABB.new(origin, max_x, max_z)
        
        self.add_child(temp.mesh)
        
        # Stick our new aabb in each of our sorted arrays, as appropriate.
        index = aabbs_east.bsearch_custom(temp, GrowAABB, "sort_by_east")
        aabbs_east.insert(index, temp)
        index = aabbs_west.bsearch_custom(temp, GrowAABB, "sort_by_west")
        aabbs_west.insert(index, temp)
        index = aabbs_north.bsearch_custom(temp, GrowAABB, "sort_by_north")
        aabbs_north.insert(index, temp)
        index = aabbs_south.bsearch_custom(temp, GrowAABB, "sort_by_south")
        aabbs_south.insert(index, temp)
        # Stick it in our viables list
        viable_aabbs.append(temp)

    $Timer.start()

func _process(delta):
    for grow in aabbs_east:
        # North
        dd.draw_line_3d(
            grow.a, 
            Vector3(grow.b.x, grow.a.y, grow.a.z),
            Color.white
        )
        # South
        dd.draw_line_3d(
            Vector3(grow.a.x, grow.a.y, grow.b.z), 
            grow.b,
            Color.red
        )
        # East
        dd.draw_line_3d(
            Vector3(grow.b.x, grow.a.y, grow.a.z),
            grow.b,
            Color.blue
        )
        # West
        dd.draw_line_3d(
            grow.a, 
            Vector3(grow.a.x, grow.a.y, grow.b.z),
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
        
        if grow.east_state == SideState.OPEN:
            # Grow to the east
            result = grow.grow_east()
            
            # If there's no problem...
            if result == SideState.OPEN:
                # Find our spot in the west array
                index = aabbs_west.bsearch_custom(
                    grow, GrowAABB, "sort_by_west"
                )
                # Get all the points east of our western-most point
                sliced_aabb = aabbs_west.slice(index, len(aabbs_west) - 1)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_east()
                        grow.east_state = SideState.GROW_BLOCKED
                        print("Blocked East!")
                        break
            else:
                grow.east_state = result
        
        if grow.south_state == SideState.OPEN:
            # Grow to the south
            result = grow.grow_south()
            
            # If there's no problem...
            if result == SideState.OPEN:
                # Find our spot in the north array
                index = aabbs_north.bsearch_custom(
                    grow, GrowAABB, "sort_by_north"
                )
                # Get all the points south of our northern-most point
                sliced_aabb = aabbs_north.slice(index, len(aabbs_north) - 1)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_south()
                        grow.south_state = SideState.GROW_BLOCKED
                        break
                if grow.b.z >= UPPER_Z_LIM:
                    grow.south_state = SideState.GROW_BLOCKED
            else:
                grow.south_state = result
        
        if grow.west_state == SideState.OPEN:
            # Grow to the west
            result = grow.grow_west()
            
            # If there's no problem...
            if result == SideState.OPEN:
                # Find our spot in the east array
                index = aabbs_east.bsearch_custom(
                    grow, GrowAABB, "sort_by_east"
                )
                # Get all the points west of our eastern-most point (including
                # ourselves)
                sliced_aabb = aabbs_east.slice(0, index)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_west()
                        grow.west_state = SideState.GROW_BLOCKED
                        break
            else:
                grow.west_state = result
        
        if grow.north_state == SideState.OPEN:
            # Grow to the north
            result = grow.grow_north()
            
             # If there's no problem...
            if result == SideState.OPEN:
                # Find our spot in the south array
                index = aabbs_south.bsearch_custom(
                    grow, GrowAABB, "sort_by_south"
                )
                # Get all the points north of our southern-most point
                # (including ourselves)
                sliced_aabb = aabbs_south.slice(0, index)
                
                for aabb in sliced_aabb:
                    if aabb != grow and grow.collides_with(aabb):
                        grow.shrink_north()
                        grow.north_state = SideState.GROW_BLOCKED
                        break
                if grow.a.z <= LOWER_Z_LIM:
                    grow.north_state = SideState.GROW_BLOCKED
            else:
                grow.north_state = result
        
        if grow.is_viable():
            new_viables.append(grow)
    viable_aabbs = new_viables

    if not viable_aabbs.empty():
        $Timer.start()
