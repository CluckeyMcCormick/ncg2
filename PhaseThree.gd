extends Spatial

# Where do we look for maps?
const IN_MAP_PATH = "res://blocks/trenchbroom_maps/"
# Where do we write the derivative maps to?
const OUT_MAP_PATH = "user://"
# How many derivatives do we make for each map?
const MAP_DERIVATIVE_COUNT = 5

# What's the inverse scale factor do we use when making the Qodot blocks?
const BLOCK_INVERSE_SCALE = 128
# How big is the side of one block, in Qodot units?
const QODOT_BLOCK_SIDE_LENGTH = 1024
# Using the last two constants, what is our Godot unit side-length?
const BLOCK_SIDE_LENGTH = QODOT_BLOCK_SIDE_LENGTH / BLOCK_INVERSE_SCALE

# What are the QodotMap nodes we're going to look at?
var map_nodes = []

# Called when the node enters the scene tree for the first time.
func _ready():
    
    print("run")
    
    # Create a blank file pointer - we'll need this later to test whether files
    # exist
    var file = File.new()
    
    # Now we need to dynamically build up our list of blocks we can use. To do
    # so, we're gonna take a look at the blocks directory and see what we can
    # do.
    var dir = Directory.new()
    # If the directory didn't open, then we can't really do anything at all.
    # Ergo, we'll have to back out.
    if dir.open(IN_MAP_PATH) != OK:
        print("Couldn't load TrenchBroom Maps directory! Can't do anything!!!")
        return
    
    # Start the directory-listing-processing thing.
    dir.list_dir_begin(true)
    
    # Randomize so we get some PROPER RANDOM SHIFTING
    randomize()
    
    var z_shift = 0
    
    # Get the first file in the directory listing
    var file_name = dir.get_next()
    # While we still have a file...
    while file_name != "":        
        # If the current file is a directory, get the next filename and skip!
        if dir.current_is_dir():
            file_name = dir.get_next()
            continue
        # If it's not a map, get the next filename and skip!
        if not ".map" in file_name:
            file_name = dir.get_next()
            continue
        # If it's an import, get the next filename and skip!
        if ".import" in file_name:
            file_name = dir.get_next()
            continue
        
        # Okay, we have a valid map. Now we need to make derivatives. First,
        # let's break the map up into it's constituent parts:
        var only_name = file_name.get_file().get_basename()
        var extension = file_name.get_extension()
        
        # Okay, now we need to make derivatives for each.
        for i in range(MAP_DERIVATIVE_COUNT):
            # Cook up this derivative's name
            var cur_deriv = OUT_MAP_PATH + only_name
            cur_deriv += "_d" + str(i + 1)
            cur_deriv += "." + extension
            
            # If the file doesn't exist, then we'll MAKE IT EXIST!!!
            if not file.file_exists(cur_deriv):
                make_single_derivative(IN_MAP_PATH + file_name, cur_deriv)
            
            # Okay, now we need to make a QodotMap Node for this derivative.
            var new_qodot = QodotMap.new()
            # Stick it under the "cached maps" section
            $CachedMaps.add_child(new_qodot)
            # Also stick it in our list of map nodes
            map_nodes.append(new_qodot)
            
            # Shift the qodot map
            new_qodot.translation.x = i * BLOCK_SIDE_LENGTH
            new_qodot.translation.z = z_shift
            
            # Update the Inverse Scale Factor
            new_qodot.inverse_scale_factor = BLOCK_INVERSE_SCALE
            
            # Give it the path to the current derivative map
            new_qodot.map_file = ProjectSettings.globalize_path(cur_deriv)
            
            # BUILD IT!!!
            new_qodot.verify_and_build()
        
        # That's done! Increment our z_shift by the appropriate factor
        z_shift += BLOCK_SIDE_LENGTH
        
        if z_shift >= 8:
            break
        
        # Now that we've checked the filename and done any necessary actions,
        # get the next file name.
        file_name = dir.get_next()
    
    # Finish off the directory listing processing... thing.
    dir.list_dir_end()

func make_single_derivative(in_path, out_path):
    
    var in_map = File.new()
    in_map.open(in_path, File.READ)
    var out_map = File.new()
    out_map.open(out_path, File.WRITE)
    
    while not in_map.eof_reached():
        var line = in_map.get_line()
        var keyword_index = line.find("building_horizontal_window")
        
        if keyword_index == -1:
            out_map.store_line(line)
            continue
        
        var new_line = line.substr(0, keyword_index)
        var old_line_comp = line.substr(keyword_index).split(" ", false)
        
        new_line += old_line_comp[0]
        new_line += " " + str((randi() % 64) * 64 + float(old_line_comp[1]))
        new_line += " " + str((randi() % 64) * 64 + float(old_line_comp[2]))
        new_line += " " + old_line_comp[3]
        new_line += " " + old_line_comp[4]
        new_line += " " + old_line_comp[5]
        out_map.store_line(new_line)

    in_map.close()
    out_map.close()
