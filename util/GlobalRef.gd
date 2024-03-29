extends Node

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# ~~~~~~~~~~~~~~~~~~~~~
#
# Fundamental Constants
#
# ~~~~~~~~~~~~~~~~~~~~~
# We assume that the 'window texture' is made up of a square of cells. How many
# cells make up one length of the image? This should be 64, but we're not going
# to take that for granted.
const WINDOW_CELL_LEN = 64

# We measure each building by the number of 'cells' - in other words, the
# windows. So we need to know how big, in world units, each cell is. Turns out,
# Godot makes it so that each texture automatically sizes itself to one world
# unit. Since our texture SHOULD be 64 cells by 64 cells, one world unit divided
# by WINDOW_CELL_LEN gets us the measure of a cell in the world.
const WINDOW_UV_SIZE = 1.0 / WINDOW_CELL_LEN

# To handle the city's lights, we use a series of square noise textures. We'll
# consider each pixel of that texture to be a window unit. So, how many window
# units/pixels long are these noise textures on one side?
const LIGHT_NOISE_LEN = 512

# Using the above variable, what's the UV length for one pixel/window cell in
# the light noise texture?
const LIGHT_NOISE_UV_SIZE = 1.0 / LIGHT_NOISE_LEN

# ~~~~~~~~~~~~~~~~
#
# Filepaths 
#
# ~~~~~~~~~~~~~~~~

# What's the user path?
const PATH_USER = "user://"

# Where do we save and load user profiles from?
const PATH_USER_PROFILES = PATH_USER + "profiles/"

# Where do we save and load user mods from?
const PATH_USER_MODS = PATH_USER + "mods/"

# Where do we save and load user antennae textures from?
const PATH_USER_ANTENNAE = PATH_USER + "textures/antennae/"

# Where do we save and load user particle textures from?
const PATH_USER_PARTICLES = PATH_USER + "textures/particles/"

# Where do we save and load user moon textures from?
const PATH_USER_MOON = PATH_USER + "textures/moon/"

# Where do we save and load user window textures from?
const PATH_USER_WINDOWS = PATH_USER + "textures/windows/"

# Iterable list of all the above constants
const PATH_USER_MANIFEST = [
    PATH_USER_PROFILES, PATH_USER_MODS, PATH_USER_ANTENNAE, PATH_USER_PARTICLES,
    PATH_USER_MOON, PATH_USER_WINDOWS
]

# ~~~~~~~~~~~~~~~~
#
# Enums
#
# ~~~~~~~~~~~~~~~~
# We support multiple window algorithms - after all, the sequence in which we
# place the windows results in a unique look for each texture.
enum WindowAlgorithm {
    RANDOM = 0
    HORIZONTAL = 1
    VERTICAL = 2
    DIAGONAL = 3
    ANTI_DIAGONAL = 4
}

# We have three different types of building materials - which means different
# sorts of windows, colors, etc. 
enum BuildingMaterial {
    A = 0, B = 1, C = 2
}

# ~~~~~~~~~~~~~~~~
#
# Groups
#
# ~~~~~~~~~~~~~~~~
const light_group = "lights"
const light_group_one = "lights_one"
const light_group_two = "lights_two"
const light_group_three = "lights_three"
const light_group_four = "lights_four"

const beacon_group = "beacons"
const beacon_group_a = "beacons_a"
const beacon_group_b = "beacons_b"
const beacon_group_c = "beacons_c"

const box_group = "roof_boxes"

const antenna_group = "antennae"
const antenna_group_1 = "antennae_1"
const antenna_group_2 = "antennae_2"
const antenna_group_3 = "antennae_3"
