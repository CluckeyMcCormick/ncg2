tool
extends Spatial

# Load the PolyGen script
const PolyGen = preload("res://util/PolyGen.gd")

# We assume that the 'window texture' is made up of a square of cells. How many
# cells make up one length of the image? This should be 64, but we're not going
# to take that for granted.
const WINDOW_CELL_LEN = 64
# We measure each building by the number of 'cells' - in other words, the
# windows. So we need to know how big, in world units, each cell is. Turns out,
# Godot makes it so that each texture automatically sizes itself to one world
# unit. Since our texture SHOULD be 64 cells by 64 cells, one world unit divided
# by WINDOW_CELL_LEN gets us the measure of a cell in the world.
const WINDOW_UV_SIZE = 1.0 / WINDOW_CELL_LEN

# By default, the UV2 texture is centered on 0,0 - so it stretches half it's
# length in either direction on x and z. While that normally wouldn't be
# a problem, with our pixel-perfect texture, it bisects one of the windows
# IF the measure on that side is odd. So we need to shift it to the side by
# half of the size of a window.
const odd_UV2_shift = Vector2(WINDOW_UV_SIZE / 2, 0)

# The material we'll use to make this building.
export(Material) var building_material

# The length (in total number of cells) of each side of the building. It's a
# rectangular prism, so we measure the length on each axis.
export(int) var len_x = 8 setget set_length_x
export(int) var len_y = 16 setget set_length_y
export(int) var len_z = 8 setget set_length_z

# Do we use the window texture for this auto-tower, or do we ignore them?
export(bool) var use_window_texture = true

# Do we auto-build on entering the scene?
export(bool) var auto_build = true setget set_auto_build

# Called when the node enters the scene tree for the first time.
func _ready():
    if auto_build:
        make_building()

# --------------------------------------------------------
#
# Setters and Getters
#
# --------------------------------------------------------
func set_length_x(new_length):
    len_x = new_length
    if Engine.editor_hint and auto_build:
        make_building()

func set_length_y(new_length):
    len_y = new_length
    if Engine.editor_hint and auto_build:
        make_building()
    
func set_length_z(new_length):
    len_z = new_length
    if Engine.editor_hint and auto_build:
        make_building()

func set_auto_build(new_autobuild):
    auto_build = new_autobuild
    if Engine.editor_hint and auto_build:
        make_building()

# --------------------------------------------------------
#
# Build Functions
#
# --------------------------------------------------------
func calculate_cell_uv_shift(side_len, random_add : bool = true):
    # We'll stick the return value into this Vector2
    var return_val
    
    if random_add:
        return_val = Vector2(randi() % WINDOW_CELL_LEN, randi() % WINDOW_CELL_LEN)
        return_val *= WINDOW_UV_SIZE
    else:
        return_val = Vector2.ZERO
    
    # Next, shift the Vector2 as appropriate for the input side length. Using
    # the parity to scale the shift allows us to skip using an if/else.
    return_val += (side_len % 2) * odd_UV2_shift
    
    return return_val

func make_building():
    
    # If we don't have the building nodes for whatever reason, back out
    if not (self.has_node("ZNeg") or self.has_node("ZPos") or \
    self.has_node("XNeg") or self.has_node("XPos") ):
        return
    
    # Calculate the world-unit length on each axis given the window/cell count
    var eff_x = (len_x * WINDOW_UV_SIZE) / 2
    var eff_y = len_y * WINDOW_UV_SIZE
    var eff_z = (len_z * WINDOW_UV_SIZE) / 2
    
    $ZNeg.mesh = ready_side_mesh(
        Vector2(-eff_x, 0),
        Vector2( eff_x, eff_y),
        -eff_z, false, calculate_cell_uv_shift(len_x)
    )
    $ZPos.mesh = ready_side_mesh(
        Vector2(-eff_x, eff_y),
        Vector2( eff_x, 0),
        eff_z, false, calculate_cell_uv_shift(len_x)
    )
    $XNeg.mesh = ready_side_mesh(
        Vector2(-eff_z, 0),
        Vector2( eff_z, eff_y),
        eff_x, true, calculate_cell_uv_shift(len_z)
    )
    $XPos.mesh = ready_side_mesh(
        Vector2(-eff_z, eff_y),
        Vector2( eff_z, 0),
        -eff_x, true, calculate_cell_uv_shift(len_z)
    )
    $YTop.mesh = ready_top_mesh(
        Vector2(-eff_x, -eff_z),
        Vector2( eff_x,  eff_z),
        eff_y
    )

func ready_side_mesh(pointA, pointB, axis_point, is_x, shift):
    var new_mesh = Mesh.new()
    var verts = PoolVector3Array()
    var UVs = PoolVector2Array()
    
    # Points and such
    var pd
    
    # UV Vector2 points
    var uvA
    var uvB
    
    # If we're using a window texture for this building...
    if self.use_window_texture:
        # Then the uv2 is the points we were given PLUS our dedicated shift
        uvA = pointA + shift
        uvB = pointB + shift
    # Otherwise...
    else:
        # We'll make both points 0-0, effectively removing the texture from this
        # building
        uvA = Vector2.ZERO
        uvB = Vector2.ZERO
    
    if is_x:
        pd = PolyGen.create_xlock_face(
            # Point A, Point B, Position on X
            pointA, pointB, axis_point,
            # Custom UV positions
            uvA, uvB
        )
    else:
        pd = PolyGen.create_zlock_face(
            # Point A, Point B, Position on Z
            pointA, pointB, axis_point,
            # Custom UV positions
            uvA, uvB
        )
    verts.append_array( pd[PolyGen.VECTOR3_KEY] )
    UVs.append_array( pd[PolyGen.UV_KEY] )
    
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    st.set_material(building_material)

    for v in verts.size():
        st.add_uv(UVs[v])
        st.add_vertex(verts[v])

    st.generate_normals()
    st.generate_tangents()

    st.commit(new_mesh)
    return new_mesh

func ready_top_mesh(pointA, pointB, axis_point):
    var new_mesh = Mesh.new()
    var verts = PoolVector3Array()
    var UVs = PoolVector2Array()
    
    # Points and such
    var pd
    
    pd = PolyGen.create_ylock_face(
        # Point A, Point B, Position on Y
        pointA, pointB, axis_point,
        # Pass in zero-zero for the UV values, meaning the roof won't have a
        # texture - exactly what we want!
        Vector2.ZERO, Vector2.ZERO
    )
    
    verts.append_array( pd[PolyGen.VECTOR3_KEY] )
    UVs.append_array( pd[PolyGen.UV_KEY] )
    
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    st.set_material(building_material)

    for v in verts.size():
        st.add_uv(UVs[v])
        st.add_vertex(verts[v])

    st.generate_normals()
    st.generate_tangents()

    st.commit(new_mesh)
    return new_mesh
