extends Node

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

# We support multiple window algorithms - after all, the sequence in which we
# place the windows results in a unique look for each texture.
enum WindowAlgorithm {
    RANDOM = 0
    HORIZONTAL = 1
    VERTICAL = 2
    DIAGONAL = 3
    ANTI_DIAGONAL = 4
}

# ~~~~~~~~~~~~~~~~
#
# Groups
#
# ~~~~~~~~~~~~~~~~
const light_group_one = "lights_one"
const light_group_two = "lights_two"
const light_group_three = "lights_three"
const light_group_four = "lights_four"

const beacon_group_a = "beacon_a"
const beacon_group_b = "beacon_b"
const beacon_group_c = "beacon_c"

const box_group = "roof_boxes"
