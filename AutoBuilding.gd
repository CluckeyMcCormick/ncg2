extends Spatial

export(Material) var building_material

var len_x = 3
var len_y = 5
var len_z = 2

# Load the PolyGen script
const PolyGen = preload("res://util/PolyGen.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
    make_building()

func make_building():
    $ZNeg.mesh = ready_mesh(Vector2(0, 0), Vector2(1, 1), -1, false, Vector2(0, 0))

func ready_mesh(pointA, pointB, axis_point, is_x, uv2_shift):    
    var new_mesh = Mesh.new()
    var verts = PoolVector3Array()
    var UVs = PoolVector2Array()
    var UV2s = PoolVector2Array()
    
    var length = 1
    
    # Points and such
    var pd
    
    # Face 1: X-Positive
    if is_x:
        pd = PolyGen.create_xlock_face_simple(pointA, pointB, axis_point, uv2_shift)
    else:
        pd = PolyGen.create_zlock_face_simple(pointA, pointB, axis_point, uv2_shift)
    verts.append_array( pd[PolyGen.VECTOR3_KEY] )
    UVs.append_array( pd[PolyGen.UV_KEY] )
    UV2s.append_array( pd[PolyGen.UV2_KEY] )
    
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
