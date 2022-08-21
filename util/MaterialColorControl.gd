extends Node

# ~~~~~~~~~~~~~~~~
#
# Resource Loads
#
# ~~~~~~~~~~~~~~~~

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# Load the Image Generator script
const ImageGenerator = preload("res://window_gen/WindowGenerator.gd")

# Load our different materials
const dot_mat_a = preload("res://buildings/DotWindowLightMaterial_V2_A.tres")
const dot_mat_b = preload("res://buildings/DotWindowLightMaterial_V2_B.tres")
const dot_mat_c = preload("res://buildings/DotWindowLightMaterial_V2_C.tres")
# These need to be var because otherwise we can't modify the "Albedo Color"
# member variable.
var star_a_material = preload("res://effects/StarTypeA.tres")
var star_b_material = preload("res://effects/StarTypeB.tres")
var star_c_material = preload("res://effects/StarTypeC.tres")
var beacon_a_material = preload("res://effects/BeaconTypeA.tres")
var beacon_b_material = preload("res://effects/BeaconTypeB.tres")
var beacon_c_material = preload("res://effects/BeaconTypeC.tres")
var sparkle_a_material = preload("res://effects/SparkleTypeA.tres")
var sparkle_b_material = preload("res://effects/SparkleTypeB.tres")
var sparkle_c_material = preload("res://effects/SparkleTypeC.tres")

# These meshes allow us to easily change the size of the sparkle particles
var sparkle_a_mesh = preload("res://effects/SparkleQuadMeshTypeA.tres")
var sparkle_b_mesh = preload("res://effects/SparkleQuadMeshTypeB.tres")
var sparkle_c_mesh = preload("res://effects/SparkleQuadMeshTypeC.tres")

# Grab the Sparkle particle material
var sparkle_particles = preload("res://effects/SparkleParticalMaterial.tres")

# What's our environment resource?
var city_env = preload("res://environment/city_env.tres")
# What's our procedural sky resource?
var city_proc_sky = preload("res://environment/city_proc_sky.tres")

# Load the moon material. NEEDS to be a var, not a const.
var moon_material = preload("res://effects/MoonMaterial.tres")

# What's the first profile that we default to?
const default_profile = preload("res://profiles/Niteflyte.tres")

# ~~~~~~~~~~~~~~~~
#
#  Variables
#
# ~~~~~~~~~~~~~~~~

# Assign the three active materials to the DotWindowLightMaterial_V2 shaders. We
# use these intermediary variables so we can avoid tying code to a specific
# preloaded material.
var mat_a = dot_mat_a
var mat_b = dot_mat_b
var mat_c = dot_mat_c

var texture_gen_a = ImageGenerator.WindowGenerator.new()
var texture_gen_b = ImageGenerator.WindowGenerator.new()
var texture_gen_c = ImageGenerator.WindowGenerator.new()

# What's the minimum height, in building-windows, that a building has to be in
# order for it to have beacons? Since this is a global contraint, this is the
# best place for it.
var min_beacon_height = 35

# The dictionary that makes up our profile object
var profile_dict = {}

# ~~~~~~~~~~~~~~~~
#
# Signals
#
# ~~~~~~~~~~~~~~~~
signal key_update(key)

# ~~~~~~~~~~~~~~~~
#
# Functions
#
# ~~~~~~~~~~~~~~~~
func _ready():
    profile_dict = default_profile.to_dict()
    
    mat_a.set_shader_param("DotTexture", texture_gen_a.texture)
    mat_b.set_shader_param("DotTexture", texture_gen_b.texture)
    mat_c.set_shader_param("DotTexture", texture_gen_c.texture)
    
    regenerate_texture_a()
    regenerate_texture_b()
    regenerate_texture_c()
    
# Asserts the current values into the dictionary
func update_whole_dictionary():
    for key in profile_dict.keys():
        update_key(key)

func regenerate_texture_a():
    regenerate_generic("bld_a_texture_set", "bld_a_algorithm", texture_gen_a)

func regenerate_texture_b():
    regenerate_generic("bld_b_texture_set", "bld_b_algorithm", texture_gen_b)

func regenerate_texture_c():
    regenerate_generic("bld_c_texture_set", "bld_c_algorithm", texture_gen_c)

func regenerate_generic(texture_key, algorithm_key, generator):
    var window
    var images = []
    
    # For each window path we need to load...
    for path in profile_dict[texture_key]:
        # Load the resource
        window = load( path )
        
        # If we didn't get anything, skip this path
        if window == null:
            print( "Could not load image at ", path )
            continue
        
        # If what we loaded is not an image or a texture, skip this path!
        if not (window is Image or window is Texture):
            print("Invalid window image ", window)
            continue
        
        if window is Texture:
            window = window.get_data()
        
        images.append(window)
    
    # If the user didn't select any images, paint a blank canvas and back out
    if images.empty():
        generator.paint_blank()
        return
    
    # Paint using the user's selected algorithm
    match profile_dict[algorithm_key]:
        GlobalRef.WindowAlgorithm.RANDOM:
            generator.paint_random(images)
            
        GlobalRef.WindowAlgorithm.HORIZONTAL:
            generator.paint_horizontal(images)
            
        GlobalRef.WindowAlgorithm.VERTICAL:
            generator.paint_vertical(images)
            
        GlobalRef.WindowAlgorithm.DIAGONAL:
            generator.paint_diagonal(images)
            
        GlobalRef.WindowAlgorithm.ANTI_DIAGONAL:
            generator.paint_anti_diagonal(images)

# Some of the keys above have special processing when their values are updated.
# Rather than performing all the special processing actions all at once, we have
# this function - it will perform only the special processing actions for the
# given key. This allows us to perform updates piecemeal.
func update_key(key):
    match key:
        #
        # Building A
        #
        "bld_a_base_color":
            mat_a.set_shader_param("BuildingColor", profile_dict[key])
        "bld_a_red_dot":
            mat_a.set_shader_param("RedDotColor", profile_dict[key])
        "bld_a_red_mixer":
            mat_a.set_shader_param(
                "RedDotLightMix", profile_dict[key] / 1000.0
            )
        "bld_a_green_dot":
            mat_a.set_shader_param("GreenDotColor", profile_dict[key])
        "bld_a_green_mixer":
            mat_a.set_shader_param(
                "GreenDotLightMix", profile_dict[key] / 1000.0
            )
        "bld_a_blue_dot":
            mat_a.set_shader_param("BlueDotColor", profile_dict[key])
        "bld_a_blue_mixer":
            mat_a.set_shader_param(
                "BlueDotLightMix", profile_dict[key] / 1000.0
            )
        #
        # Building B
        #
        "bld_b_base_color":
            mat_b.set_shader_param("BuildingColor", profile_dict[key])
        "bld_b_red_dot":
            mat_b.set_shader_param("RedDotColor", profile_dict[key])
        "bld_b_red_mixer":
            mat_b.set_shader_param(
                "RedDotLightMix", profile_dict[key] / 1000.0
            )
        "bld_b_green_dot":
            mat_b.set_shader_param("GreenDotColor", profile_dict[key])
        "bld_b_green_mixer":
            mat_b.set_shader_param(
                "GreenDotLightMix", profile_dict[key] / 1000.0
            )
        "bld_b_blue_dot":
            mat_b.set_shader_param("BlueDotColor", profile_dict[key])
        "bld_b_blue_mixer":
            mat_b.set_shader_param(
                "BlueDotLightMix", profile_dict[key] / 1000.0
            )
        #
        # Building C
        #
        "bld_c_base_color":
            mat_c.set_shader_param("BuildingColor", profile_dict[key])
        "bld_c_red_dot":
            mat_c.set_shader_param("RedDotColor", profile_dict[key])
        "bld_c_red_mixer":
            mat_c.set_shader_param(
                "RedDotLightMix", profile_dict[key] / 1000.0
            )
        "bld_c_green_dot":
            mat_c.set_shader_param("GreenDotColor", profile_dict[key])
        "bld_c_green_mixer":
            mat_c.set_shader_param(
                "GreenDotLightMix", profile_dict[key] / 1000.0
            )
        "bld_c_blue_dot":
            mat_c.set_shader_param("BlueDotColor", profile_dict[key])
        "bld_c_blue_mixer":
            mat_c.set_shader_param(
                "BlueDotLightMix", profile_dict[key] / 1000.0
            )
        #
        # Lights
        #
        "lights_one_color":
            get_tree().call_group(
                GlobalRef.light_group_one, "set_color", profile_dict[key]
            )
        "lights_two_color":
            get_tree().call_group(
                GlobalRef.light_group_two, "set_color", profile_dict[key]
            )
        "lights_three_color":
            get_tree().call_group(
                GlobalRef.light_group_three, "set_color", profile_dict[key]
            )
        "lights_four_color":
            get_tree().call_group(
                GlobalRef.light_group_four, "set_color", profile_dict[key]
            )
        "lights_one_visible":
            get_tree().call_group(
                GlobalRef.light_group_one, "set_visible", profile_dict[key]
            )
        "lights_two_visible":
            get_tree().call_group(
                GlobalRef.light_group_two, "set_visible", profile_dict[key]
            )
        "lights_three_visible":
            get_tree().call_group(
                GlobalRef.light_group_three, "set_visible", profile_dict[key]
            )
        "lights_four_visible":
            get_tree().call_group(
                GlobalRef.light_group_four, "set_visible", profile_dict[key]
            )
        #
        # Sky
        #
        "sky_sky_top":
            city_proc_sky.sky_top_color = profile_dict[key]
        "sky_sky_horizon":
            city_proc_sky.sky_horizon_color = profile_dict[key]
        "sky_sky_curve":
            city_proc_sky.sky_curve = profile_dict[key] / 10000.0
        "sky_ground_horizon":
            city_proc_sky.ground_horizon_color = profile_dict[key]
        "sky_ground_bottom":
            city_proc_sky.ground_bottom_color = profile_dict[key]
        "sky_ground_curve":
            city_proc_sky.ground_curve = profile_dict[key] / 10000.0
        "sky_x_rotation":
            var current_rot = city_env.get_sky_rotation_degrees()
            current_rot.x = profile_dict[key]
            city_env.set_sky_rotation_degrees(current_rot)
        
        #
        # Stars
        #
        "stars_type_a_texture":
            var star_texture = load( profile_dict[key] )
            if star_texture != null:
                star_a_material.albedo_texture = star_texture
            else:
                print( "Could not load image at ", profile_dict[key] )
        "stars_type_b_texture":
            var star_texture = load( profile_dict[key] )
            if star_texture != null:
                star_b_material.albedo_texture = star_texture
            else:
                print( "Could not load image at ", profile_dict[key] )
        "stars_type_c_texture":
            var star_texture = load( profile_dict[key] )
            if star_texture != null:
                star_c_material.albedo_texture = star_texture
            else:
                print( "Could not load image at ", profile_dict[key] )
        "stars_type_a_color":
            star_a_material.albedo_color = profile_dict[key]
        "stars_type_b_color":
            star_b_material.albedo_color = profile_dict[key]
        "stars_type_c_color":
            star_c_material.albedo_color = profile_dict[key]
        
        #
        # Moon
        #
        "moon_color":
            moon_material.albedo_color = profile_dict[key]

        #
        # Beacons
        #
        "beacon_texture_a":
            var beacon_texture = load( profile_dict[key] )
            if beacon_texture != null:
                beacon_a_material.albedo_texture = beacon_texture
            else:
                print( "Could not load image at ", profile_dict[key] )
        "beacon_texture_b":
            var beacon_texture = load( profile_dict[key] )
            if beacon_texture != null:
                beacon_b_material.albedo_texture = beacon_texture
            else:
                print( "Could not load image at ", profile_dict[key] )
        "beacon_texture_c":
            var beacon_texture = load( profile_dict[key] )
            if beacon_texture != null:
                beacon_c_material.albedo_texture = beacon_texture
            else:
                print( "Could not load image at ", profile_dict[key] )
        "beacon_color_a":
            beacon_a_material.albedo_color = profile_dict[key]
        "beacon_color_b":
            beacon_b_material.albedo_color = profile_dict[key]
        "beacon_color_c":
            beacon_c_material.albedo_color = profile_dict[key]
        "beacon_size_a":
            beacon_a_material.params_point_size = profile_dict[key]
        "beacon_size_b":
            beacon_b_material.params_point_size = profile_dict[key]
        "beacon_size_c":
            beacon_c_material.params_point_size = profile_dict[key]
        "beacon_correction_a":
            get_tree().call_group(
                GlobalRef.beacon_group_a,
                "set_height_correction", profile_dict[key]
            )
        "beacon_correction_b":
            get_tree().call_group(
                GlobalRef.beacon_group_b,
                "set_height_correction", profile_dict[key]
            )
        "beacon_correction_c":
            get_tree().call_group(
                GlobalRef.beacon_group_c,
                "set_height_correction", profile_dict[key]
            )
        "beacon_height":
            min_beacon_height = profile_dict[key]
            get_tree().call_group(GlobalRef.beacon_group_a, "beacon_update")
            get_tree().call_group(GlobalRef.beacon_group_b, "beacon_update")
            get_tree().call_group(GlobalRef.beacon_group_c, "beacon_update")
        "beacon_enabled":
            get_tree().call_group(
                GlobalRef.beacon_group_a, "set_enabled", profile_dict[key]
            )
            get_tree().call_group(
                GlobalRef.beacon_group_b, "set_enabled", profile_dict[key]
            )
            get_tree().call_group(
                GlobalRef.beacon_group_c, "set_enabled", profile_dict[key]
            )
        
        #
        # Sparkles
        #
        "sparkle_texture_a":
            var sparkle_texture = load( profile_dict[key] )
            if sparkle_texture != null:
                sparkle_a_material.albedo_texture = sparkle_texture
            else:
                print( "Could not load image at ", profile_dict[key] )
        "sparkle_texture_b":
            var sparkle_texture = load( profile_dict[key] )
            if sparkle_texture != null:
                sparkle_b_material.albedo_texture = sparkle_texture
            else:
                print( "Could not load image at ", profile_dict[key] )
        "sparkle_texture_c":
            var sparkle_texture = load( profile_dict[key] )
            if sparkle_texture != null:
                sparkle_c_material.albedo_texture = sparkle_texture
            else:
                print( "Could not load image at ", profile_dict[key] )
        "sparkle_color_a":
            sparkle_a_material.albedo_color = profile_dict[key]
        "sparkle_color_b":
            sparkle_b_material.albedo_color = profile_dict[key]
        "sparkle_color_c":
            sparkle_c_material.albedo_color = profile_dict[key]
        "sparkle_size_a":
            sparkle_a_mesh.size.x = profile_dict[key]
            sparkle_a_mesh.size.y = profile_dict[key]
        "sparkle_size_b":
            sparkle_b_mesh.size.x = profile_dict[key]
            sparkle_b_mesh.size.y = profile_dict[key]
        "sparkle_size_c":
            sparkle_c_mesh.size.x = profile_dict[key]
            sparkle_c_mesh.size.y = profile_dict[key]
        "sparkle_scale":
            sparkle_particles.scale = profile_dict[key]
        "sparkle_scale_random":
            sparkle_particles.scale_random = profile_dict[key]
        
    # Tell everyone that we're updating
    emit_signal("key_update", key)
