tool
extends Spatial

# Load the PolyGen script
const PolyGen = preload("res://util/PolyGen.gd")
# We measure each building by the number of 'cells' - in other words, the
# windows. So we need to know how big, in world units, each cell is. Turns out,
# Godot makes it so that each texture automatically sizes itself to one world
# unit. Since our texture is 32 cells by 32 cells, the one world unit divided by
# 32 gets us the measure of a cell in the world.
const WINDOW_UV_SIZE = 1.0 / 32.0
# Because we're using a texture for the top of the building, we have to pull
# some special crap to "select" the texture depending on the height. What's the
# max height a building can be before we default to the untextured top?
const MAX_TEXTURED_TOP_HEIGHT = 6
# We use two different textures for the tops of buildings - a "lower" one for
# lower buildings, and a "higher" one for higher buildings. At what height do we
# designate the "lower" building (inlusive)?
const TOP_LOW_SPLIT = 4

export(Material) var building_side_material
export(Material) var building_top_material

export(int) var len_x = 3 setget set_length_x
export(int) var len_y = 6 setget set_length_y
export(int) var len_z = 2 setget set_length_z

# Called when the node enters the scene tree for the first time.
func _ready():
    make_building()

# --------------------------------------------------------
#
# Setters and Getters
#
# --------------------------------------------------------
func set_length_x(new_length):
    len_x = new_length
    if Engine.editor_hint:
        make_building()

func set_length_y(new_length):
    len_y = new_length
    if Engine.editor_hint:
        make_building()
    
func set_length_z(new_length):
    len_z = new_length
    if Engine.editor_hint:
        make_building()
     

# --------------------------------------------------------
#
# Build Functions
#
# --------------------------------------------------------
func make_building():
    
    var eff_x = (len_x * WINDOW_UV_SIZE) / 2
    var eff_y = len_y * WINDOW_UV_SIZE
    var eff_z = (len_z * WINDOW_UV_SIZE) / 2
    
    # By default, the UV2 texture is centered on 0,0 - so it stretches half it's
    # length in either direction on x and z. While that normally wouldn't be
    # a problem, with our pixel-perfect texture, it bisects one of the windows.
    # So we need to shift it to the side by half of the size of a window.
    var base_UV2_shift = Vector2(WINDOW_UV_SIZE / 2, 0)
    
    $ZNeg.mesh = ready_side_mesh(
        Vector2(-eff_x, 0), 
        Vector2( eff_x, eff_y), 
        -eff_z, false, base_UV2_shift
    )
    $ZPos.mesh = ready_side_mesh( 
        Vector2(-eff_x, eff_y),
        Vector2( eff_x, 0), 
        eff_z, false, base_UV2_shift
    )
    $XNeg.mesh = ready_side_mesh(
        Vector2(-eff_z, 0), 
        Vector2( eff_z, eff_y), 
        eff_x, true, Vector2.ZERO
    )
    $XPos.mesh = ready_side_mesh( 
        Vector2(-eff_z, eff_y),
        Vector2( eff_z, 0), 
        -eff_x, true, Vector2.ZERO
    )
    $YTop.mesh = ready_top_mesh(
        Vector2(-eff_x, -eff_z),
        Vector2( eff_x,  eff_z), 
        eff_y, len_y
    )

func ready_side_mesh(pointA, pointB, axis_point, is_x, uv2_shift):    
    var new_mesh = Mesh.new()
    var verts = PoolVector3Array()
    var UVs = PoolVector2Array()
    var UV2s = PoolVector2Array()
    
    # Points and such
    var pd
    
    if is_x:
        pd = PolyGen.create_xlock_face_simple(pointA, pointB, axis_point, uv2_shift)
    else:
        pd = PolyGen.create_zlock_face_simple(pointA, pointB, axis_point, uv2_shift)
    verts.append_array( pd[PolyGen.VECTOR3_KEY] )
    UVs.append_array( pd[PolyGen.UV_KEY] )
    UV2s.append_array( pd[PolyGen.UV2_KEY] )
    
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    st.set_material(building_side_material)

    for v in verts.size():
        st.add_uv(UVs[v])
        st.add_uv2(UV2s[v])
        st.add_vertex(verts[v])

    st.generate_normals()
    st.generate_tangents()

    st.commit(new_mesh)
    return new_mesh

func ready_top_mesh(pointA, pointB, axis_point, texture_level):    
    var new_mesh = Mesh.new()
    var verts = PoolVector3Array()
    var UVs = PoolVector2Array()
    
    var level_color
    
    # Points and such
    var pd
    
    pd = PolyGen.create_ylock_face_simple(pointA, pointB, axis_point, Vector2.ZERO)
    
    verts.append_array( pd[PolyGen.VECTOR3_KEY] )
    UVs.append_array( pd[PolyGen.UV_KEY] )
    
    # Now we're gonna prebake some information about height into the top mesh so
    # the shader for the top will actually work. Magic Numbers abound!
    match texture_level:
        6:
            # Use Blue Channel, Upper Texture
            level_color = Color(0, 0, 1.0, 1.0)
        5:
            # Use Green Channel, Upper Texture
            level_color = Color(0, 1.0, 0, 1.0)
        4:
            # Use Green Channel, Upper Texture
            level_color = Color(1.0, 0, 0, 1.0)
        3:
            # Use Red Channel, Lower Texture
            level_color = Color(0, 0, 1.0, 0)
        2:
            # Use Red Channel, Lower Texture
            level_color = Color(0, 1.0, 0, 0)
        1:
            # Use Red Channel, Lower Texture
            level_color = Color(1.0, 0, 0, 0)
        _:
            # Special code, No Texture, Dark Color
            level_color = Color(0, 0, 0, 1.0)
    
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    st.set_material(building_top_material)

    for v in verts.size():
        st.add_uv(UVs[v])
        st.add_color(level_color)
        st.add_vertex(verts[v])

    st.generate_normals()
    st.generate_tangents()

    st.commit(new_mesh)
    return new_mesh
