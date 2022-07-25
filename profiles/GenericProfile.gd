extends Resource
class_name GenericProfile

export var profile_name = "Hiroshi Nagai's Niteflyte"

export var building = {
    "bld_base_color": Color("#000d20"),
    "bld_red_dot": Color("#77121a"),
    "bld_red_mixer": 1000,
    "bld_green_dot": Color("#98c7d1"),
    "bld_green_mixer": 1000,
    "bld_blue_dot": Color("#d1cc64"),
    "bld_blue_mixer": 1000,
    "bld_texture_path": "res://buildings/textures/dots64_horizontal64_75hs.png",
}

export var sky = {
    "sky_sky_top": Color("#003f96"),
    "sky_sky_horizon": Color("#9f84b7"),
    "sky_sky_curve": 365,
    "sky_ground_horizon": Color("#003f96"),
    "sky_ground_bottom": Color("#070a1b"),
    "sky_ground_curve": 200,
    "sky_x_rotation": 1.0,
}

export var light = {
    "lights_one_color": Color("002459"),
    "lights_two_color": Color("002459"),
    "lights_three_color": Color("002459"),
    "lights_four_color": Color("002459"),

    "lights_one_visible": true,
    "lights_two_visible": true,
    "lights_three_visible": true,
    "lights_four_visible": true,
}

export var starfield = {
    "starfield_height": 15.0,
    "starfield_type_a_count": 20,
    "starfield_type_b_count": 20,
    "starfield_type_c_count": 20,
    "starfield_scale_mean": 1.7,
    "starfield_scale_variance": .3,
}

export var stars = {
    "stars_type_a_color": Color.white,
    "stars_type_a_texture": "res://effects/star_textures/64Dot.png",
    "stars_type_b_color": Color.white,
    "stars_type_b_texture": "res://effects/star_textures/64Dot.png",
    "stars_type_c_color": Color.white,
    "stars_type_c_texture": "res://effects/star_textures/64Dot.png",
}

export var moon = {
    "moon_visible": true,
    "moon_color": Color.white,
    "moon_x_pos": -10.0,
    "moon_y_pos": 5.55,
    "moon_size": 1.9,
}

func to_dict():
    var dict = { "profile_name": profile_name }
    
    for key in building.keys():
        dict[key] = building[key]
    
    for key in sky.keys():
        dict[key] = sky[key]
    
    for key in light.keys():
        dict[key] = light[key]
    
    for key in starfield.keys():
        dict[key] = starfield[key]
    
    for key in stars.keys():
        dict[key] = stars[key]
    
    for key in moon.keys():
        dict[key] = moon[key]

    return dict
