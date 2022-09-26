
const GlobalRef = preload("res://util/GlobalRef.gd")

# This stage-script randomly determines what kind of material the building is
# going to be, then assigns that material as part of its build process. This
# relies on the global MCC being present.

# Pick a material for the building.
static func make_blueprint(blueprint : Dictionary):
    var values = GlobalRef.BuildingMaterial.values()
    blueprint["material_enum"] = values[ randi() % len(values) ]

# Pass the chosen material to the autotower.
static func make_construction(building : Spatial, blueprint : Dictionary):
    # Get the MaterialColorControl, using the building
    var mcc = building.get_node("/root/MaterialColorControl")
    var autotower = building.get_node("AutoTower")
    
    # If there's no Material Color Control, back out!
    if mcc == null:
        printerr("Could not access MCC to set building material!")
        return
    
    # If there's no AutoTower, back out!
    if autotower == null:
        printerr("Could not access AutoTower to set building material!")
        return
    
    # Set the material appropriately given the material enum.
    match blueprint["material_enum"]:
        GlobalRef.BuildingMaterial.A:
            autotower.building_material = mcc.mat_a
            
        GlobalRef.BuildingMaterial.B:
            autotower.building_material = mcc.mat_b
            
        GlobalRef.BuildingMaterial.C:
            autotower.building_material = mcc.mat_c
