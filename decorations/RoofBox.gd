extends Spatial

# The length (in total number of cells) of each side of the box. It's a
# rectangular prism, so we measure the length on each axis.
export(float) var len_x = 1 setget set_length_x
export(float) var len_y = .5 setget set_length_y
export(float) var len_z = 1 setget set_length_z

# The material we'll use to make this box.
export(Material) var material setget set_material

# --------------------------------------------------------
#
# Setters and Getters
#
# --------------------------------------------------------
func set_length_x(new_length):
    len_x = new_length
    $AutoTower.len_x = len_x

func set_length_y(new_length):
    len_y = new_length
    $AutoTower.len_y = len_y
    
func set_length_z(new_length):
    len_z = new_length
    $AutoTower.len_z = len_z

func set_material(new_material):
    material = new_material
    $AutoTower.building_material = material

# --------------------------------------------------------
#
# Build Functions
#
# --------------------------------------------------------
func make_box():
    $AutoTower.make_building()
    
