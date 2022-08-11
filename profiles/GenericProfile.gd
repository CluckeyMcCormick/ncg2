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
    "stars_type_a_texture": "res://effects/particle_textures/hard_dot.png",
    "stars_type_b_color": Color.white,
    "stars_type_b_texture": "res://effects/particle_textures/hard_dot.png",
    "stars_type_c_color": Color.white,
    "stars_type_c_texture": "res://effects/particle_textures/hard_dot.png",
}

export var moon = {
    "moon_visible": true,
    "moon_color": Color.white,
    "moon_x_pos": -10.0,
    "moon_y_pos": 5.55,
    "moon_size": 1.9,
}

export var beacon = {
    "beacon_texture_a": "res://effects/particle_textures/hard_dot.png",
    "beacon_texture_b": "res://effects/particle_textures/hard_dot.png",
    "beacon_texture_c": "res://effects/particle_textures/hard_dot.png",
    "beacon_color_a": Color("#77121a"),
    "beacon_color_b": Color("#98c7d1"),
    "beacon_color_c": Color("#d1cc64"),
    "beacon_size_a": 5.0,
    "beacon_size_b": 5.0,
    "beacon_size_c": 5.0,
    "beacon_correction_a": .25,
    "beacon_correction_b": .25,
    "beacon_correction_c": .25,
    "beacon_height": 35,
    "beacon_enabled": false
}

export var sparkle = {
    "sparkle_texture_a": "res://effects/particle_textures/hard_dot.png",
    "sparkle_texture_b": "res://effects/particle_textures/hard_dot.png",
    "sparkle_texture_c": "res://effects/particle_textures/hard_dot.png",
    "sparkle_color_a": Color("#77121a"),
    "sparkle_color_b": Color("#98c7d1"),
    "sparkle_color_c": Color("#d1cc64"),
    "sparkle_size_a": .5,
    "sparkle_size_b": .5,
    "sparkle_size_c": .5,
    "sparkle_count_a": 2,
    "sparkle_count_b": 2,
    "sparkle_count_c": 2,
    "sparkle_lifetime_a": 2.5,
    "sparkle_lifetime_b": 2.5,
    "sparkle_lifetime_c": 2.5,
    "sparkle_randomness_a": 1.0,
    "sparkle_randomness_b": 1.0,
    "sparkle_randomness_c": 1.0,
    "sparkle_enabled_a": false,
    "sparkle_enabled_b": false,
    "sparkle_enabled_c": false,
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

    for key in beacon.keys():
        dict[key] = beacon[key]
        
    for key in sparkle.keys():
        dict[key] = sparkle[key]

    return dict
