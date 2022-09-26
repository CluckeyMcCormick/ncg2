extends Spatial

const MATERIALS = [
    preload("res://voronoi/VoroniColorA.tres"),
    preload("res://voronoi/VoroniColorB.tres"),
    preload("res://voronoi/VoroniColorC.tres"),
    preload("res://voronoi/VoroniColorD.tres"),
    preload("res://voronoi/VoroniColorE.tres"),
    preload("res://voronoi/VoroniColorF.tres"),
    preload("res://voronoi/VoroniColorG.tres"),
    preload("res://voronoi/VoroniColorH.tres"),
    preload("res://voronoi/VoroniColorI.tres"),
    preload("res://voronoi/VoroniColorJ.tres"),
]

const GlobalRef = preload("res://util/GlobalRef.gd")
const GROW_BLOCKIFIER = preload("res://grow_points/GrowBlockifier.gd")
const SECONDARY_NODE = preload("res://grow_points/SecondaryNode.tscn")
const BUILDING_SCENE = preload("res://buildings/FootprintBuilding.tscn")

const X_WIDTH = 30
const Z_LENGTH = 200
const TARGET_BLOCKS = 8

var blockifier = null

func _ready():
    var new_node
    
    # Set some default values
    $GUI/OptionsBox/XBox.value = X_WIDTH
    $GUI/OptionsBox/ZBox.value = Z_LENGTH
    $GUI/OptionsBox/BuildingBox.value = 40
    
    # Sneak in our own construction stage
    $GrowBlockCityAlt/BuildingFactory.construction_stages.append(self)
    
    # Start the build process
    start_build()

func start_build():
    # If we're cleaning up the buildings...
    if $"%CleanToggle".pressed:
        $GrowBlockCityAlt.clean_buildings()
    
    # Load GUI values
    $GrowBlockCityAlt.block_x_width = $GUI/OptionsBox/XBox.value
    $GrowBlockCityAlt.block_z_length = $GUI/OptionsBox/ZBox.value
    $GrowBlockCityAlt.buildings_per_block = $GUI/OptionsBox/BuildingBox.value
    $GrowBlockCityAlt.blocks = TARGET_BLOCKS
    
    # Disable the regenerate button
    $"%RegenerateButton".disabled = true
    
    # Start the chain!
    $GrowBlockCityAlt.start_make_chain()

func _on_CameraOptions_item_selected(index):
    if index == 0:
        $OrthoDownCamera.current = true
    elif index == 1:
        $FOV30Camera.current = true
    else:
        $FOV15Camera.current = true

func _on_RegenerateButton_pressed():
    start_build()

func _on_GrowBlockCityAlt_city_complete():
    print("City Complete!")
    # Reenable the regenerate button
    $"%RegenerateButton".disabled = false

# One of the advantages of the Building Factory is that you can easily add your
# own steps - case in point, this function. We sneak it in to quickly override
# the standard materials with bright debug materials.
func make_construction(building : Spatial, blueprint : Dictionary):
    var autotower = building.get_node("AutoTower")
    
    autotower.building_material = MATERIALS[ randi() % len(MATERIALS) ]
    
    autotower.make_building()
