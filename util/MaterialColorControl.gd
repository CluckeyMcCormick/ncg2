extends Node

# Load our different materials
const dot_material = preload("res://buildings/DotWindowMaterial.tres")
const dot_light_material = preload("res://buildings/DotWindowLightMaterial.tres")
# These need to be var because otherwise we can't modify the "Albedo Color"
# member variable.
var type_a_material = preload("res://effects/StarTypeA.tres")
var type_b_material = preload("res://effects/StarTypeB.tres")
var type_c_material = preload("res://effects/StarTypeC.tres")

# Load our different star textures
const s64_dot = preload("res://effects/64Dot.png")
const s64_star = preload("res://effects/64Star.png")
const s64_sparkle_a = preload("res://effects/64Sparkles50a.png")
const s64_sparkle_b = preload("res://effects/64Sparkles50b.png")
const s64_sparkle_c = preload("res://effects/64Sparkles50c.png")

# Load the moon material. NEEDS to be a var, not a const.
var moon_material = preload("res://effects/MoonMaterial.tres")

# This controls what materials new buildings come out as.
var primary_material = dot_light_material

var profile_dict = {
    "bld_base_color": Color("#000d20"),
    "bld_red_dot": Color("#77121a"),
    "bld_green_dot": Color("#98c7d1"),
    "bld_blue_dot": Color("#d1cc64"),
    "bld_texture_path": "res://buildings/dots64_horizontal64_75hs.png",
    
    "sky_sky_top": Color("#003f96"),
    "sky_sky_horizon": Color("#9f84b7"),
    "sky_sky_curve": 365,
    "sky_ground_horizon": Color("#003f96"),
    "sky_ground_bottom": Color("#070a1b"),
    "sky_ground_curve": 200,
    
    "starfield_height": 15,
    "starfield_type_a_count": 20,
    "starfield_type_b_count": 20,
    "starfield_type_c_count": 20,
    "starfield_scale_mean": 1.7,
    "starfield_scale_variance": .3,
    
    "stars_type_a_color": Color.white,
    "stars_type_a_texture": 0,
    "stars_type_b_color": Color.white,
    "stars_type_b_texture": 0,
    "stars_type_c_color": Color.white,
    "stars_type_c_texture": 0,
    
    "moon_visible": true,
    "moon_color": Color.white,
    "moon_x_pos": -10,
    "moon_y_pos": 5.55,
    "moon_size": 1.25,
}

func dictionary_assert():
    
    var window_texture = load( profile_dict["bld_texture_path"] )
    if window_texture != null:
        primary_material.set_shader_param("DotTexture", window_texture)
        primary_material.set_shader_param("DotTextureLight", window_texture)
    else:
        print("Could not load image at ", profile_dict["bld_texture_path"])
    primary_material.set_shader_param("BuildingColor", profile_dict["bld_base_color"])
    primary_material.set_shader_param("RedDotColor", profile_dict["bld_red_dot"])
    primary_material.set_shader_param("GreenDotColor", profile_dict["bld_green_dot"])
    primary_material.set_shader_param("BlueDotColor", profile_dict["bld_blue_dot"])
