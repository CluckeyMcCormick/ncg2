extends Node

# This script is a "manifest" in the sense that it's just lists - like how a
# shipping manifest is a list of items. Anyway, we have two lists here,
# implemented as arrays: one for blueprint stages, and one for construction
# stages. These need to be filled with objects, though, in truth, we don't
# really care what the objects are - they just need to have certain functions.
# I would recommend using (pre)loaded scripts.

# This manifest will be what the Building Factory defaults to - while it doesn't
# preclude alteration in an individual Factory instance, these are the stages
# the Building Factory will copy upon entering the scene.

# Those objects in blueprint_stages need to have a "make_blueprint" function
# that accepts a dictionary.
var blueprint_stages = [
    preload("res://factory/stages/MaterialStage.gd"), # Determine the material
    preload("res://factory/stages/TransformStage.gd"), # Determine the Transform
    preload("res://factory/stages/LightStage.gd")
]

# Those objects in construction_stages need to have a "make_construction"
# function that accepts a node and a dictionary.
var construction_stages = [
    preload("res://factory/stages/MaterialStage.gd"), # Set the material
    preload("res://factory/stages/TransformStage.gd"), # Set the Transform
    preload("res://factory/stages/AutoTowerBuildStage.gd"), # Build the tower
    preload("res://factory/stages/LightStage.gd")
]
