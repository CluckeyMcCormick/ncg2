extends Node

# Load our different materials
const dot_material = preload("res://buildings/DotWindowMaterial.tres")
const dot_light_material = preload("res://buildings/DotWindowLightMaterial.tres")
# These need to be var because otherwise we can't modify the "Albedo Color"
# member variable.
var star_a_material = preload("res://effects/StarTypeA.tres")
var star_b_material = preload("res://effects/StarTypeB.tres")
var star_c_material = preload("res://effects/StarTypeC.tres")

var city_proc_sky = preload("res://environment/city_proc_sky.tres")

# Load our different star textures
#const s64_dot = preload("res://effects/64Dot.png")
#const s64_star = preload("res://effects/64Star.png")
#const s64_sparkle_a = preload("res://effects/64Sparkles50a.png")
#const s64_sparkle_b = preload("res://effects/64Sparkles50b.png")
#const s64_sparkle_c = preload("res://effects/64Sparkles50c.png")

# Load the moon material. NEEDS to be a var, not a const.
var moon_material = preload("res://effects/MoonMaterial.tres")

const default_profile = preload("res://profiles/Niteflyte.tres")

# This controls what materials new buildings come out as.
var primary_material = dot_light_material

var profile_dict = {}

func _ready():
    profile_dict = default_profile.to_dict()
    
# Asserts the current values into the dictionary
func update_whole_dictionary():
    for key in profile_dict.keys():
        key_update(key)

# Some of the keys above have special processing when their values are updated.
# Rather than performing all the special processing actions all at once, we have
# this function - it will perform only the special processing actions for the
# given key. This allows us to perform updates piecemeal.
func key_update(key):
    match key:
        #
        # Building
        #
        "bld_texture_path":
            var window_texture = load( profile_dict[key] )
            if window_texture != null:
                primary_material.set_shader_param(
                    "DotTexture", window_texture
                )
                primary_material.set_shader_param(
                    "DotTextureLight", window_texture
                )
            else:
                print( "Could not load image at ", profile_dict[key] )
        "bld_base_color":
            primary_material.set_shader_param("BuildingColor", profile_dict[key])
        "bld_red_dot":
            primary_material.set_shader_param("RedDotColor", profile_dict[key])
        "bld_green_dot":
            primary_material.set_shader_param("GreenDotColor", profile_dict[key])
        "bld_blue_dot":
            primary_material.set_shader_param("BlueDotColor", profile_dict[key])
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
            pass
        "stars_type_b_color":
            star_b_material.albedo_color = profile_dict[key]
            pass
        "stars_type_c_color":
            star_c_material.albedo_color = profile_dict[key]
            pass
        
        #
        # Moon
        #
        "moon_color":
            moon_material.albedo_color = profile_dict[key]

