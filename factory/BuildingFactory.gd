extends Node

# Preload the TemplateBuilding scene, since we'll be needing to spawn this.
const TemplateBuilding = preload("res://factory/TemplateBuilding.tscn")

# Signal emitted when a blueprint-construction thread is completed. Emits the
# blueprint for the building to be constructed, along with the thread id.
signal blueprint_completed(blueprint)

# Get the FactoryStageManifest. We have this as a global node so that other
# mods can hook in and modify the default blueprint and contruction stages.
onready var manifest = get_node("/root/FactoryStageManifest")

# What stages do we execute when creating blueprints?
var blueprint_stages = []

# What stages do we execute when constructing from a blueprint?
var construction_stages = []

# We have to keep track of our thread objects so we can close them properly:
# we'll store them in this Array.
var threads = []

# What's the standard deviation for the rotation of any given building on a
# sled? This is a "deviation" in the terms of a Gaussian Distribution, meaning
# that 68% will be within plus-or-minus this value.
export(float) var rotation_deviation = 45

# --------------------------------------------------------
#
# Godot Functions
#
# --------------------------------------------------------

func _ready():
    # Disable our physics processing
    set_physics_process(false)
    
    # If we didn't get a manifest, we can't do anything! Back out
    if manifest == null:
        printerr("Couldn't initialize Building Factory manifest!")
        return
    
    # Create shallow duplicates of the blueprint and construction stages.
    blueprint_stages = manifest.blueprint_stages.duplicate()
    construction_stages = manifest.construction_stages.duplicate()

func _physics_process(_delta):
    # What threads will make it to the next processing round?
    var ongoing_threads = []
    # The blueprint returned by a thread
    var blueprint
    
    # If we're out of threads, disable the physics processing and back out
    if threads.empty():
        set_physics_process(false)
        return
    
    # Okay, while we still have threads to look at...
    for curr_thread in threads:
        
        # If this thread is still going, skip it!
        if curr_thread.is_alive():
            ongoing_threads.append(curr_thread)
            continue
        
        # Okay, we're good to go - wait for the thread to finish; this will
        # return a complete blueprint.
        blueprint = curr_thread.wait_to_finish()
        
        # Tell the world!
        emit_signal("blueprint_completed", blueprint)
        
        # Now we do nothing! The thread will fade into the background,
        # dereferenced and deleted.
        
    # Update our thread array!
    threads = ongoing_threads

# --------------------------------------------------------
#
# Build Functions
#
# --------------------------------------------------------

# A wrapper for make_blueprint that runs it in a thread.
func start_make_blueprint_thread(footprint_x, footprint_z, len_y, origin, scale):
    # Any errors?
    var err

    # What's our new thread?
    var thread = Thread.new()
    
    # What's our blueprint dictionary?
    var dict
    
    # Generate a dictionary
    dict = _create_basic_blueprint(
        footprint_x, footprint_z, len_y, origin, scale
    )
    
    # Start the thread
    err = thread.start(self, "_make_blueprint", dict)

    # No issues? Great! Start physics processing!
    if err == OK:
        # If physics processing is already running, then this will just double
        # down. Idempotence, baby!
        set_physics_process(true)
        
        # Stick our threads in the thread array
        threads.append(thread)
    
    # Otherwise, we failed. Nullify the thread.
    else:
        thread = null
        printerr("Error!: ", err)
    
    # Return true if we successfully started a thread.
    return err == OK

# Creates a blueprint dictionary and returns it. Unfortunately because threaded
# functions must only accept one argument, we just call the _make_blueprint
# function, which has the actual functionality in there.
func make_blueprint(footprint_x, footprint_z, len_y, origin, scale):
    # Generate a basic blueprint dictionary
    var dict = _create_basic_blueprint(
        footprint_x, footprint_z, len_y, origin, scale
    )
    
    # Call the actual function
    dict = _make_blueprint(dict)
    
    # Return the blueprint dictionary
    return dict

# Fills the given blueprint dictionary.
func _make_blueprint(blueprint : Dictionary):
    
    # Now for the good stuff - for each blueprint stage...
    for stage in blueprint_stages:
        # Call the make blueprint function!
        stage.make_blueprint(blueprint)
    
    return blueprint

func construct_building(building_parent : Spatial, blueprint : Dictionary):
    # Create a Template Building
    var template_building = TemplateBuilding.instance()
    
    # Stick it under the building parent
    building_parent.add_child(template_building)
    
    # Now for the good stuff - let's actually make this building!
    for stage in construction_stages:
        # Call the make construction function!
        stage.make_construction(template_building, blueprint)
    
    return template_building

# --------------------------------------------------------
#
# Utility Functions
#
# --------------------------------------------------------

# We have like three different blueprint functions so we need this one to create
# a template dictionary.
func _create_basic_blueprint(footprint_x, footprint_z, len_y, origin, scale):
    return {
        "footprint_x": footprint_x, "footprint_z": footprint_z,
        "len_x": max(footprint_x - 1, 1), "len_z": max(footprint_z - 1, 1),
        "len_y": len_y, "origin": origin, "scale": scale,
        "rotation_deviation": rotation_deviation
    }
