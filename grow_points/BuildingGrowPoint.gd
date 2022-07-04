# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")
const SECONDARY_NODE = preload("res://grow_points/SecondaryNode.tscn")

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
    
    var height = 10
    
    var east_state = SideState.OPEN
    var south_state = SideState.OPEN
    var north_state = SideState.OPEN
    var west_state = SideState.OPEN
    
    static func sort_by_east(one, two):
        return one.b.x < two.b.x
    
    static func sort_by_south(one, two):
        return one.b.z < two.b.z
        
    static func sort_by_west(one, two):
        return one.a.x < two.a.x
    
    static func sort_by_north(one, two):
        return one.a.z < two.a.z

    func _init(in_origin, in_max_x_len, in_max_z_len, in_height):
        origin = in_origin
        
        a = origin
        b = origin
        
        max_x_len = in_max_x_len
        max_z_len = in_max_z_len
        
        height = in_height
    
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
