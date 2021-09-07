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