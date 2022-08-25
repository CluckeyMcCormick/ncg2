extends Spatial

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

# TODO: Implement this layered moon concept with shaders and generated textures,
# not two images. Not that there's anything wrong with two images, mind you; but
# we could probably get much more dynamic textures if we did this with a shader.
# This a pretty low priority, but it might be a nice-to-have.

# Called when the node enters the scene tree for the first time.
func _ready():
    # Connect to the key update signal, so we can respond to key changes.
    mcc.connect("key_update", self, "_on_mcc_key_update")

func _on_mcc_key_update(key):
    match key:
        "moon_front_color":
            $Forward.modulate = mcc.profile_dict[key]
        "moon_front_texture":
            $Forward.texture = load(mcc.profile_dict[key])
        "moon_front_mirror_x":
            $Forward.flip_h = mcc.profile_dict[key]
        "moon_front_mirror_y":
            $Forward.flip_v = mcc.profile_dict[key]
        "moon_front_rotation":
            $Forward.rotation_degrees.z = mcc.profile_dict[key]
        
        "moon_back_color":
            $Back.modulate = mcc.profile_dict[key]
        "moon_back_texture":
            $Back.texture = load(mcc.profile_dict[key])
        "moon_back_mirror_x":
            $Back.flip_h = mcc.profile_dict[key]
        "moon_back_mirror_y":
            $Back.flip_v = mcc.profile_dict[key]
        "moon_back_rotation":
            $Back.rotation_degrees.z = mcc.profile_dict[key]

        "moon_size":
            $Forward.pixel_size = mcc.profile_dict[key] / 1000.0
            $Back.pixel_size = mcc.profile_dict[key] / 1000.0
