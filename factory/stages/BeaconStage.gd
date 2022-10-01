
# This script creates the building beacons, which I'm honestly not that crazy
# about but sometimes they look okay.

# Load the GlobalRef script so we have that
const GlobalRef = preload("res://util/GlobalRef.gd")

# Load the Beacon script so we can refer to that when we need to.
const BeaconScript = preload("res://decorations/Beacon.gd")

# This function gets called first, in the blueprint stage. This one will most
# likely be run from a thread, so you must avoid creating nodes in it. This is
# where the "planning" should take place, and can be algorithmically complex as
# you need - after all, it's threaded. Any values you wish to carry over to the
# construction stage should be placed in the blueprint Dictionary.
static func make_blueprint(blueprint : Dictionary):
    # Get the various beacon types
    var beacon_types = BeaconScript.BeaconType.values()
    
    # Randomly pick a beacon type and save it
    blueprint["beacon_type"] = beacon_types[
        blueprint["rngen"].randi() % len( beacon_types )
    ]
    
    # Pick a random occurrence value
    blueprint["beacon_occurrence"] = blueprint["rngen"].randi_range(
        0, BeaconScript.OCCURRENCE_MAX
    )

# This function gets called after make_blueprint, in the construction stage.
# This function wil not be run from a thread; here is where nodes are spawned
# and placed appropriately. However, it's not threaded, so take care and ensure
# the function isn't too complex. The provided building is a TemplateBuilding,
# any modifications should be made to that node. The blueprint dictionary is the
# same one from the make_blueprint function call.
#
# This function doesn't necessarily need to be static, but you do need it if
# you're just going to call this script directly without instancing it or
# attaching it to something.
static func make_construction(building : Spatial, blueprint : Dictionary):
    # Load the beacon scene
    var Beacon = load("res://decorations/Beacon.tscn")
    
    # Grab the Tower FX node
    var towerFX = building.get_node("AutoTower/BuildingFX")
    
    # Calculate the "realspace" X and Z
    var real_x = blueprint["len_x"] * GlobalRef.WINDOW_UV_SIZE
    var real_z = blueprint["len_z"] * GlobalRef.WINDOW_UV_SIZE
    
    # Create 4 Beacons
    var beacon_a = Beacon.instance()
    var beacon_b = Beacon.instance()
    var beacon_c = Beacon.instance()
    var beacon_d = Beacon.instance()
    
    # Stick the 4 beacons under the tower's FX node
    towerFX.add_child(beacon_a)
    towerFX.add_child(beacon_b)
    towerFX.add_child(beacon_c)
    towerFX.add_child(beacon_d)
    
    # Move the beacons!
    # A
    beacon_a.translation.x = real_x / 2.0
    beacon_a.translation.z = real_z / 2.0
    # B
    beacon_b.translation.x = real_x / 2.0
    beacon_b.translation.z = -real_z / 2.0
    # C
    beacon_c.translation.x = -real_x / 2.0
    beacon_c.translation.z = -real_z / 2.0
    # D
    beacon_d.translation.x = -real_x / 2.0
    beacon_d.translation.z = real_z / 2.0
    
    # Set the beacon's height
    beacon_a.curr_beacon_height = blueprint["len_y"]
    beacon_b.curr_beacon_height = blueprint["len_y"]
    beacon_c.curr_beacon_height = blueprint["len_y"]
    beacon_d.curr_beacon_height = blueprint["len_y"]
    
    # Set the beacon type
    beacon_a.type = blueprint["beacon_type"]
    beacon_b.type = blueprint["beacon_type"]
    beacon_c.type = blueprint["beacon_type"]
    beacon_d.type = blueprint["beacon_type"]
    
    # Set the occurrence rating
    beacon_a.occurrence = blueprint["beacon_occurrence"]
    beacon_b.occurrence = blueprint["beacon_occurrence"]
    beacon_c.occurrence = blueprint["beacon_occurrence"]
    beacon_d.occurrence = blueprint["beacon_occurrence"]
