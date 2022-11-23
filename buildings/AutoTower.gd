tool
extends Spatial

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")
# Load the Packed Light Scene
const PLS = preload("res://buildings/PackedLight.gd")

# Our building is actually crafted using a cube - we take the mesh and then
# manipulate the points. It's always an equal sized cube, to - how long is that
# cube on one side?
const CUBE_SIZE = 1.0

# The material we'll use to make this building.
export(Material) var building_material setget set_building_material

# The length (in total number of cells) of each side of the building. It's a
# rectangular prism, so we measure the length on each axis.
export(float, 1, 4096, 1.0) var len_x = 8 setget set_length_x
export(float, 1, 4096, 1.0) var len_y = 16 setget set_length_y
export(float, 1, 4096, 1.0) var len_z = 8 setget set_length_z

# Do we use the window texture for this auto-tower, or do we ignore them?
export(bool) var use_window_texture = true setget set_use_window_texture

# Do we auto-build on entering the scene?
export(bool) var auto_build = true setget set_auto_build

export(PLS.LightGroups) var se_group setget set_se_group
export(int, 0, 255) var se_range = 16 setget set_se_range

export(PLS.LightGroups) var ne_group setget set_ne_group
export(int, 0, 255) var ne_range = 16 setget set_ne_range

export(PLS.LightGroups) var nw_group setget set_nw_group
export(int, 0, 255) var nw_range = 16 setget set_nw_range

export(PLS.LightGroups) var sw_group setget set_sw_group
export(int, 0, 255) var sw_range = 16 setget set_sw_range

# The light data for each light.
# Light Positioned in the +x+z corner
var light_se = PLS.PackedLight.new()
# Light Positioned in the +x-z corner
var light_ne = PLS.PackedLight.new()
# Light Positioned in the -x-z corner
var light_nw = PLS.PackedLight.new()
# Light Positioned in the -x+z corner
var light_sw = PLS.PackedLight.new()

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
        randomize()
        make_building()

func set_length_y(new_length):
    len_y = new_length
    if Engine.editor_hint and auto_build:
        randomize()
        make_building()
    
func set_length_z(new_length):
    len_z = new_length
    if Engine.editor_hint and auto_build:
        randomize()
        make_building()

func set_use_window_texture(use_texture):
    use_window_texture = use_texture
    if Engine.editor_hint and auto_build:
        randomize()
        make_building()

func set_auto_build(new_autobuild):
    auto_build = new_autobuild
    if Engine.editor_hint and auto_build:
        randomize()
        make_building()

#
# Light 1
#
func set_se_group(new_group):
    se_group = new_group
    light_se.set_group(new_group)
    if Engine.editor_hint and auto_build:
        randomize()
        make_building()
func set_se_range(new_range):
    se_range = new_range
    light_se.set_range(new_range)
    if Engine.editor_hint and auto_build:
        randomize()
        make_building()

#
# Light 2
#
func set_ne_group(new_group):
    ne_group = new_group
    light_ne.set_group(new_group)
    if Engine.editor_hint and auto_build:
        randomize()
        make_building()
func set_ne_range(new_range):
    ne_range = new_range
    light_ne.set_range(new_range)
    if Engine.editor_hint and auto_build:
        randomize()
        make_building()

#
# Light 3
#
func set_nw_group(new_group):
    nw_group = new_group
    light_nw.set_group(new_group)
    if Engine.editor_hint and auto_build:
        randomize()
        make_building()
func set_nw_range(new_range):
    nw_range = new_range
    light_nw.set_range(new_range)
    if Engine.editor_hint and auto_build:
        randomize()
        make_building()

#
# Light 4
#
func set_sw_group(new_group):
    sw_group = new_group
    light_sw.set_group(new_group)
    if Engine.editor_hint and auto_build:
        randomize()
        make_building()
func set_sw_range(new_range):
    sw_range = new_range
    light_sw.set_range(new_range)
    if Engine.editor_hint and auto_build:
        randomize()
        make_building()

# --------------------------------------------------------
#
# Build Functions
#
# --------------------------------------------------------
func calculate_cell_uv_shift(rng : RandomNumberGenerator = null):
    # We'll stick the return value into this Vector2
    var return_val
    
    # If we don't have a Random Number Generator, use Godot's built in randi()
    # function
    if rng == null:
        return_val = Vector2(
            randi() % GlobalRef.WINDOW_CELL_LEN,
            randi() % GlobalRef.WINDOW_CELL_LEN
        )
    # Otherwise, use the RandomNumberGenerator object
    else:
        return_val = Vector2(
            rng.randi() % GlobalRef.WINDOW_CELL_LEN,
            rng.randi() % GlobalRef.WINDOW_CELL_LEN
        )
    
    # Scale the shift to WINDOW UV units
    return_val *= GlobalRef.WINDOW_UV_SIZE
    
    return return_val

func make_building(rng : RandomNumberGenerator = null):
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
    # the ones we need into these variables!
    var vertex
    var uv
    var color
    var uv2
    
    # We'll use these variables to dereference elements in the array we're
    # looking at.
    var curr_vert
    var curr_uv
    var curr_color
    var curr_uv2
    
    # The UV shift vectors
    var shift_north
    var shift_south
    var shift_west
    var shift_east
    
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
    
    # Spread the arrays appropriately
    vertex = arrays[ArrayMesh.ARRAY_VERTEX]
    uv = arrays[ArrayMesh.ARRAY_TEX_UV]
    
    # We're just going to assume the color array is blank, so we'll go about
    # making our own.
    color = PoolColorArray()
    
    # We're just going to assume the UV2 array is blank, so we'll go about
    # making our own.
    uv2 = PoolVector2Array()
    
    # Calculate some shifts
    shift_north = calculate_cell_uv_shift(rng)
    shift_south = calculate_cell_uv_shift(rng)
    shift_west = calculate_cell_uv_shift(rng)
    shift_east = calculate_cell_uv_shift(rng)
    
    for idx in range( vertex.size() ):
        # Grab the current vector and uv, default the uv2 and color
        curr_vert = vertex[idx]
        curr_uv = uv[idx]
        
        curr_uv2 = Vector2.ZERO
        curr_color = Color(0, 0, 0, 0)
        
        #
        # Step 1: UV2
        #
        # Pack the positions of each light into X and Y
        curr_uv2.x = PLS.float_compress(
           light_ne.to_northeast_range_int() | light_se.to_southeast_range_int()
        )
        curr_uv2.y =  PLS.float_compress(
           light_nw.to_northwest_range_int() | light_sw.to_southwest_range_int()
        )
        
        #
        # Step 2: Vertex
        #
        # Shift the height up since the cube is always centered at y 0
        curr_vert.y += CUBE_SIZE / 2
        
        # Now, scale all of the points based on the effective lengths we were
        # given.
        curr_vert.x *= eff_x / CUBE_SIZE
        curr_vert.y *= eff_y / CUBE_SIZE
        curr_vert.z *= eff_z / CUBE_SIZE
        
        #
        # Step 3: Vertex Color
        #
        curr_color.r = light_se.to_compressed_group()
        curr_color.g = light_ne.to_compressed_group()
        curr_color.b = light_nw.to_compressed_group()
        curr_color.a = light_sw.to_compressed_group()
        
        #
        # Step 4: UV
        #
        match idx:
            # South face is 0 2 4 6
            0, 2, 4, 6:
                # We want the UVs to be between 0 and 1, so use the round
                # function to force the range we want.
                curr_uv = curr_uv.ceil()
                # Scale UV's x using our X
                curr_uv.x *= eff_x
                # Scale up the UV's y - it's ALWAYS our effective y
                curr_uv.y *= eff_y
                # Shift using the appropriate vector
                curr_uv += shift_south
            # North face is 1 3 5 7
            1, 3, 5, 7:
                # For some reason the X ranges between 0.66 and 1 so subtract
                # out .5
                curr_uv.x -= .5
                # Now round to force between 0 and 1
                curr_uv = curr_uv.round()
                # Scale UV's x using our X
                curr_uv.x *= eff_x
                # Scale up the UV's y - it's ALWAYS our effective y
                curr_uv.y *= eff_y
                # Shift using the appropriate vector
                curr_uv += shift_north
            # East face is 8 10 12 14
            8, 10, 12, 14:
                # Round to force between 0 and 1
                curr_uv = curr_uv.round()
                # Scale UV's x using our Z
                curr_uv.x *= eff_z
                # Scale up the UV's y - it's ALWAYS our effective y
                curr_uv.y *= eff_y
                # Shift using the appropriate vector
                curr_uv += shift_east
            # West face is 9 11 13 15
            9, 11, 13, 15:
                # UV X values typically range between 0 and .33, so add .3
                curr_uv.x += .3
                # UV Y values typically range between .5 and 1, so subtract .25
                curr_uv.y -= .25
                # Round to force between 0 and 1
                curr_uv = curr_uv.round()
                # Scale UV's x using our Z
                curr_uv.x *= eff_z
                # Scale up the UV's y - it's ALWAYS our effective y
                curr_uv.y *= eff_y
                # Shift using the appropriate vector
                curr_uv += shift_west
            # Top face is 16 18 20 22
            16, 18, 20, 22:
                # Blank the UV - no textures on this face!
                curr_uv *= 0
            # Bottom face is 17 19 21 23
            17, 19, 21, 23:
                # Blank the UV - no textures on this face!
                curr_uv *= 0
        
        # If we're not using window textures, blank the UV
        if not use_window_texture:
            curr_uv *= 0
        
        # Assert the modified values
        vertex[idx] = curr_vert
        uv[idx] = curr_uv
        color.append(curr_color)
        uv2.append(curr_uv2)
    
    # Assert the updated arrays in the array-of-arrays
    arrays[ArrayMesh.ARRAY_VERTEX] = vertex
    arrays[ArrayMesh.ARRAY_TEX_UV] = uv
    arrays[ArrayMesh.ARRAY_COLOR] = color
    arrays[ArrayMesh.ARRAY_TEX_UV2] = uv2
    
    $BuildingMesh.mesh.add_surface_from_arrays(
        Mesh.PRIMITIVE_TRIANGLES,
        arrays, [], 0
    )

    $BuildingMesh.mesh.regen_normalmaps()

    # Set the building material
    $BuildingMesh.set_surface_material(0, building_material)
    
