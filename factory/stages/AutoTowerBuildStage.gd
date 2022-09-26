
# This script is the actual construction step for the AutoTower.

# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

static func make_blueprint(blueprint : Dictionary):
    # Nothing to do here!
    pass

# Set the lengths of the AutoTower and actually make the building.
static func make_construction(building : Spatial, blueprint : Dictionary):
    # Get the AutoTower
    var autotower = building.get_node("AutoTower")
    # Get the Visibility node
    var visi = building.get_node("VisibilityNotifier")
    
    # Set the lengths
    autotower.len_x = blueprint["len_x"]
    autotower.len_y = blueprint["len_y"]
    autotower.len_z = blueprint["len_z"]

    # Make the building
    autotower.make_building()

    # Set Visibility AABB's position
    visi.aabb.position.x = -(blueprint["len_x"] * GlobalRef.WINDOW_UV_SIZE) / 2
    visi.aabb.position.y = 0
    visi.aabb.position.z = -(blueprint["len_z"] * GlobalRef.WINDOW_UV_SIZE) / 2
    
    # Set the Visibility AABB's size
    visi.aabb.size.x = blueprint["len_x"] * GlobalRef.WINDOW_UV_SIZE
    visi.aabb.size.y = blueprint["len_y"] * GlobalRef.WINDOW_UV_SIZE
    visi.aabb.size.z = blueprint["len_z"] * GlobalRef.WINDOW_UV_SIZE
