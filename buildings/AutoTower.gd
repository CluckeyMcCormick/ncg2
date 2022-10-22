tool
extends Spatial

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# By default, the UV2 texture is centered on 0,0 - so it stretches half it's
# length in either direction on x and z. While that normally wouldn't be
# a problem, with our pixel-perfect texture, it bisects one of the windows
# IF the measure on that side is odd. So we need to shift it to the side by
# half of the size of a window.
const odd_UV2_shift = Vector2(GlobalRef.WINDOW_UV_SIZE / 2, 0)

# Our building is actually crafted using a cube - we take the mesh and then
# manipulate the points. It's always an equal sized cube, to - how long is that
# cube on one side?
const CUBE_SIZE = 1.0

# The material we'll use to make this building.
export(Material) var building_material setget set_building_material

# The length (in total number of cells) of each side of the building. It's a
# rectangular prism, so we measure the length on each axis.
export(float) var len_x = 8 setget set_length_x
export(float) var len_y = 16 setget set_length_y
export(float) var len_z = 8 setget set_length_z

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
func set_building_material(new_material):
    building_material = new_material
    
    # If we don't have the building mesh for whatever reason, back out
    if not self.has_node("BuildingMesh"):
        return
    
    # If the building mesh doesn't have a surface for us to manipulate, back out
    if $BuildingMesh.mesh.get_surface_count() > 0:
        return
    
    # Set the building material
    $BuildingMesh.set_surface_material(0, building_material)

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
        return_val = Vector2(
            randi() % GlobalRef.WINDOW_CELL_LEN,
            randi() % GlobalRef.WINDOW_CELL_LEN
        )
        return_val *= GlobalRef.WINDOW_UV_SIZE
    else:
        return_val = Vector2.ZERO
    
    # Next, shift the Vector2 as appropriate for the input side length. Using
    # the parity to scale the shift allows us to skip using an if/else.
    return_val += (side_len % 2) * odd_UV2_shift
    
    return return_val

func make_building():
    # Calculate the world-unit length on each axis given the window/cell count
    var eff_x = len_x * GlobalRef.WINDOW_UV_SIZE
    var eff_y = len_y * GlobalRef.WINDOW_UV_SIZE
    var eff_z = len_z * GlobalRef.WINDOW_UV_SIZE
    
    # The cube mesh we'll base all of our work on
    var cube_mesh
    
    # The arrays we'll be modifying to give our array mesh - each index is a
    # different type of Array or PoolArray; see ArrayMesh.ArrayType enumeration
    # for more
    var arrays
    # Since we have multiple arrays we'll be editing, we'll just dereference
    # them into a temporary variable for shorthand - this variable!
    var curr_arr
    # We'll use this temp variable to dereference an element in the current
    # array we're looking at.
    var curr
    
    # If we don't have the building mesh for whatever reason, back out
    if not self.has_node("BuildingMesh"):
        return
    
    # Clear out our surfaces so we're not stacking surfaces on surfaces
    $BuildingMesh.mesh.clear_surfaces()
    
    # Create the cube mesh
    cube_mesh = CubeMesh.new()
    cube_mesh.size = Vector3(CUBE_SIZE, CUBE_SIZE, CUBE_SIZE)
    # Get the arrays from the cube mesh!
    arrays = cube_mesh.get_mesh_arrays()
    
    # Alright, first we're going to modify the vertex array
    curr_arr = arrays[ArrayMesh.ARRAY_VERTEX]
    for idx in range( curr_arr.size() ):
        # Grab the current vector
        curr = curr_arr[idx]
        
        # Shift the height up since the cube is always centered at y 0
        curr.y += CUBE_SIZE / 2
        
        # Now, scale all of the points based on the effective lengths we were
        # given.
        curr.x *= eff_x / CUBE_SIZE
        curr.y *= eff_y / CUBE_SIZE
        curr.z *= eff_z / CUBE_SIZE
        
        # Assert the current value in the vertex array
        curr_arr[idx] = curr
    
    # Assert the current vertex array in the array-of-arrays
    arrays[ArrayMesh.ARRAY_VERTEX] = curr_arr
    
    $BuildingMesh.mesh.add_surface_from_arrays(
        Mesh.PRIMITIVE_TRIANGLES,
        arrays
    )

    # Set the building material
    $BuildingMesh.set_surface_material(0, building_material)
#    $ZNeg.mesh = ready_side_mesh(
#        Vector2(-eff_x, 0),
#        Vector2( eff_x, eff_y),
#        -eff_z, false, calculate_cell_uv_shift(len_x)
#    )
#    $ZPos.mesh = ready_side_mesh(
#        Vector2(-eff_x, eff_y),
#        Vector2( eff_x, 0),
#        eff_z, false, calculate_cell_uv_shift(len_x)
#    )
#    $XNeg.mesh = ready_side_mesh(
#        Vector2(-eff_z, 0),
#        Vector2( eff_z, eff_y),
#        eff_x, true, calculate_cell_uv_shift(len_z)
#    )
#    $XPos.mesh = ready_side_mesh(
#        Vector2(-eff_z, eff_y),
#        Vector2( eff_z, 0),
#        -eff_x, true, calculate_cell_uv_shift(len_z)
#    )
#    $YTop.mesh = ready_top_mesh(
#        Vector2(-eff_x, -eff_z),
#        Vector2( eff_x,  eff_z),
#        eff_y
#    )
