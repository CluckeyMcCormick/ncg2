tool
extends Spatial

export(Material) var building_side_material
export(Material) var building_top_material

var len_x = 3
var len_y = 5
var len_z = 2

# Load the PolyGen script
const PolyGen = preload("res://util/PolyGen.gd")
const WINDOW_UV_SIZE = 1.0 / 32.0

# Called when the node enters the scene tree for the first time.
func _ready():
    make_building()

func make_building():
    
    var eff_x = (len_x * WINDOW_UV_SIZE) / 2
    var eff_y = len_y * WINDOW_UV_SIZE
    var eff_z = (len_z * WINDOW_UV_SIZE) / 2
    
    # By default, the UV2 texture is centered on 0,0 - so it stretches half it's
    # length in either direction on x and z. While that normally wouldn't be
    # a problem, with our pixel-perfect texture, it bisects one of the windows.
    # So we need to shift it to the side by half of the size of a window.
    var base_UV2_shift = Vector2(WINDOW_UV_SIZE / 2, 0)
    
    $ZNeg.mesh = ready_mesh_XZ(
        Vector2(-eff_x, 0), 
        Vector2( eff_x, eff_y), 
        -eff_z, false, base_UV2_shift
    )
    $ZPos.mesh = ready_mesh_XZ( 
        Vector2(-eff_x, eff_y),
        Vector2( eff_x, 0), 
        eff_z, false, base_UV2_shift
    )
    $XNeg.mesh = ready_mesh_XZ(
        Vector2(-eff_z, 0), 
        Vector2( eff_z, eff_y), 
        eff_x, true, Vector2.ZERO
    )
    $XPos.mesh = ready_mesh_XZ( 
        Vector2(-eff_z, eff_y),
        Vector2( eff_z, 0), 
        -eff_x, true, Vector2.ZERO
    )

func ready_mesh_XZ(pointA, pointB, axis_point, is_x, uv2_shift):    
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

func ready_mesh_Y(pointA, pointB, axis_point):    
    var new_mesh = Mesh.new()
    var verts = PoolVector3Array()
    var UVs = PoolVector2Array()
    var UV2s = PoolVector2Array()
    
    # Points and such
    var pd
    
    pd = PolyGen.create_ylock_face_simple(pointA, pointB, axis_point, Vector2.ZERO)
    
    verts.append_array( pd[PolyGen.VECTOR3_KEY] )
    UVs.append_array( pd[PolyGen.UV_KEY] )
    UV2s.append_array( pd[PolyGen.UV2_KEY] )
    
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    st.set_material(building_top_material)

    for v in verts.size():
        st.add_uv(UVs[v])
        st.add_uv2(UV2s[v])
        st.add_vertex(verts[v])

    st.generate_normals()
    st.generate_tangents()

    st.commit(new_mesh)
    return new_mesh
