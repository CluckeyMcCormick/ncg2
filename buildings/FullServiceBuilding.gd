tool
extends Spatial

# The material we'll use to make this building.
export(Material) var building_material setget set_building_material

# The length (in total number of cells) of each side of the building. It's a
# rectangular prism, so we measure the length on each axis.
export(int) var len_x = 8 setget set_length_x
export(int) var len_z = 8 setget set_length_z
# Ditto as above, but for the length on y of each of our two components
export(int) var base_len_y = 2 setget set_base_length_y
export(int) var tower_len_y = 14 setget set_tower_length_y

# Do we auto-build on entering the scene?
export(bool) var auto_build = true setget set_auto_build

# Called when the node enters the scene tree for the first time.
func _ready():
    if auto_build:
        make_building()

# --------------------------------------------------------
#
# Setters and Getters
#
# --------------------------------------------------------
func set_building_material(new_building_material):
    building_material = new_building_material
    if Engine.editor_hint and auto_build:
        make_building()

func set_length_x(new_length):
    len_x = new_length
    if Engine.editor_hint and auto_build:
        make_building()
    
func set_length_z(new_length):
    len_z = new_length
    if Engine.editor_hint and auto_build:
        make_building()

func set_base_length_y(new_length):
    base_len_y = new_length
    if Engine.editor_hint and auto_build:
        make_building()

func set_tower_length_y(new_length):
    tower_len_y = new_length
    if Engine.editor_hint and auto_build:
        make_building()

func set_auto_build(new_autobuild):
    auto_build = new_autobuild
    if Engine.editor_hint and auto_build:
        make_building()

# --------------------------------------------------------
#
# Build Functions
#
# --------------------------------------------------------
func make_building():
    # If we don't have the building nodes for whatever reason, back out
    if not self.has_node("Base") or not self.has_node("MainTower"):
        return
    
    # Otherwise, pass the materials down to the buildings
    $Base.building_material = building_material
    $MainTower.building_material = building_material
    
    # Pass down the values to the base
    $Base.len_x = len_x
    $Base.len_z = len_z
    $Base.len_y = base_len_y
    
    # Now, pass the values to the main tower
    $MainTower.len_x = len_x
    $MainTower.len_z = len_z
    $MainTower.len_y = tower_len_y
    
    # Now, move the tower up appropriately
    $MainTower.translation.y = $MainTower.WINDOW_UV_SIZE * base_len_y
    
    # Now build both buildings
    $Base.make_building()
    $MainTower.make_building()
