
# This script creates the building beacons, which I'm honestly not that crazy
# about but sometimes they look okay.

# Load the GlobalRef script so we have that
const GlobalRef = preload("res://util/GlobalRef.gd")

# Load the Beacon script so we can refer to that when we need to.
const BeaconScript = preload("res://decorations/Beacon.gd")

# Roll up the occurrence and type for the beacon
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

# Spawn in the beacons, move them to the correct location, set the type,
# location and height.
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
