extends Resource
class_name GenericProfile

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

export var profile_name = "Hiroshi Nagai's Niteflyte"
export var author_name = ""
export var extra_notes = ""
export var file_name = ""

export var building_a = {
    "bld_a_base_color": Color("#000d20"),
    "bld_a_red_dot": Color("#77121a"),
    "bld_a_red_mixer": 1000,
    "bld_a_green_dot": Color("#98c7d1"),
    "bld_a_green_mixer": 1000,
    "bld_a_blue_dot": Color("#d1cc64"),
    "bld_a_blue_mixer": 1000,
    "bld_a_algorithm" : 1,
    "bld_a_texture_set": ["res://window_gen/windows/dot_75p.png"],
}

export var building_b = {
    "bld_b_base_color": Color("#000d20"),
    "bld_b_red_dot": Color("#77121a"),
    "bld_b_red_mixer": 1000,
    "bld_b_green_dot": Color("#98c7d1"),
    "bld_b_green_mixer": 1000,
    "bld_b_blue_dot": Color("#d1cc64"),
    "bld_b_blue_mixer": 1000,
    "bld_b_algorithm" : 1,
    "bld_b_texture_set": ["res://window_gen/windows/dot_75p.png"],
}

export var building_c = {
    "bld_c_base_color": Color("#000d20"),
    "bld_c_red_dot": Color("#77121a"),
    "bld_c_red_mixer": 1000,
    "bld_c_green_dot": Color("#98c7d1"),
    "bld_c_green_mixer": 1000,
    "bld_c_blue_dot": Color("#d1cc64"),
    "bld_c_blue_mixer": 1000,
    "bld_c_algorithm" : 1,
    "bld_c_texture_set": ["res://window_gen/windows/dot_75p.png"],
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
    "moon_front_color": Color(0, 0, 0, 0),
    "moon_front_texture": "res://effects/moon_textures/full.png",
    "moon_front_rotation": 0.0,
    "moon_front_mirror_x": false,
    "moon_front_mirror_y": false,
    "moon_back_color": Color.white,
    "moon_back_texture": "res://effects/moon_textures/full.png",
    "moon_back_rotation": 0.0,
    "moon_back_mirror_x": false,
    "moon_back_mirror_y": false,
    "moon_x_pos": -10.0,
    "moon_y_pos": 5.55,
    "moon_size": 6.0,
}

export var beacon = {
    "beacon_texture_a": "res://effects/particle_textures/hard_dot.png",
    "beacon_texture_b": "res://effects/particle_textures/hard_dot.png",
    "beacon_texture_c": "res://effects/particle_textures/hard_dot.png",
    "beacon_color_a": Color("#000000"),
    "beacon_color_b": Color("#000000"),
    "beacon_color_c": Color("#000000"),
    "beacon_size_a": 5.0,
    "beacon_size_b": 5.0,
    "beacon_size_c": 5.0,
    "beacon_correction_a": .25,
    "beacon_correction_b": .25,
    "beacon_correction_c": .25,
    "beacon_min_height": 35,
    "beacon_max_height": 100,
    "beacon_occurrence": 100,
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
    "sparkle_scale": 1.0,
    "sparkle_scale_random" : 0.0,
}

export var box = {
    "box_min_height": 0,
    "box_max_height": 100,
    "box_occurrence": 100,
    "box_enabled": false,
    "box_extra": 1.0,
    "box_denominator": 30.0,
    "box_ratio_enabled": false,
    "box_max_count": 5
}

export var antennae = {
    "antennae_occurrence": 100,
    "antennae_enabled": false,
    "antennae_ratio_enabled": true,
    "antennae_min_height": 0,
    "antennae_max_height": 100,
    "antennae_max_count": 6,
    "antennae_texture_1": "res://decorations/antennae_textures/rod32px.png",
    "antennae_texture_2": "res://decorations/antennae_textures/rod32px.png",
    "antennae_texture_3": "res://decorations/antennae_textures/rod32px.png",
    "antennae_denominator_1": 30.0,
    "antennae_denominator_2": 30.0,
    "antennae_denominator_3": 30.0,
    "antennae_extra_1": 1.0,
    "antennae_extra_2": 1.0,
    "antennae_extra_3": 1.0,
}

func to_dict():
    var dict = {
        "profile_name": profile_name, "author_name": author_name,
        "extra_notes": extra_notes, "file_name": file_name
    }
    
    for key in building_a.keys():
        dict[key] = building_a[key]

    for key in building_b.keys():
        dict[key] = building_b[key]

    for key in building_c.keys():
        dict[key] = building_c[key]
    
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

    for key in box.keys():
        dict[key] = box[key]
    
    for key in antennae.keys():
        dict[key] = antennae[key]
    
    return dict
