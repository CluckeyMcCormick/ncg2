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

# When caching the blocks, we spawn them in real-space - how many blocks do we
# do for a row?
const BLOCKS_PER_ROW = 10

# WHAT VALUE DO WE RETURN WHEN the Build All Blocks function succeeds?
const BUILD_ALL_SUCCESS = 0

# Fires every time a block is built. Gives the godot file path (i.e. user:// or
# res://), the real file path (i.e. /home/developer/...), as well as the local
# and global positions. Not really that necessary, but useful for debuggery and
# similar situations.
signal block_built(godot_path, real_path, local_pos, global_pos)

# Here's where we'll stick the QodotMaps once we've built them - it what we'll
# use to quickly get info from the node.
var map_to_node = {}

func build_all_blocks(yield_after_build=true):
    # Create a blank file pointer - we need this to test whether files exist or
    # not.
    var existence_checker = File.new()

    # Now - we need to dynamically build up our list of blocks we can use. To do
    # so, we're gonna take a look at the blocks directory and see what we can
    # do.
    var dir = Directory.new()
    
    # If the directory didn't open, then we can't really do anything at all.
    # Ergo, we'll have to back out.
    if dir.open(IN_MAP_PATH) != OK:
        printerr("Couldn't load TrenchBroom Maps directory! Can't do anything!!!")
        return ERR_FILE_NOT_FOUND
    
    # Start the directory-listing-processing thing.
    dir.list_dir_begin(true)
    
    # Randomize so we get some PROPER RANDOM SHIFTING
    randomize()
    
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
            if not existence_checker.file_exists(cur_deriv):
                make_single_derivative(IN_MAP_PATH + file_name, cur_deriv)
            # Okay, the file exists now. Goody! Let's build it.
            build_single_block(cur_deriv)
            
            # If we're yielding everytime we build something, then yield!!!
            if yield_after_build:
                yield();
            
        # Now that we've made the derivatives and built the block, get the next
        # block-map-file.
        file_name = dir.get_next()
    
    # Finish off the directory listing processing... thing.
    dir.list_dir_end()
    
    # Return 0
    return 0
            
func build_single_block(in_path):
    # Create a blank file pointer - we need this to test whether files exist or
    # not.
    var existence_checker = File.new()
    
    # If the file doesn't exist, then throw out an error message and back out!
    if not existence_checker.file_exists(in_path):
        printerr("File ", in_path, " does not exist, cannot build!!!")
        return
    
    # Okay so the file does exist. Yipee!!! Now, if we don't have a node
    # associated with this map-path...
    if not in_path in map_to_node:
        # Okay, now we need to make a QodotMap Node.
        var new_qodot = QodotMap.new()
        # Stick it in the scene
        self.add_child(new_qodot)
            
        # Shift the qodot map
        new_qodot.translation.x = (len(map_to_node) % BLOCKS_PER_ROW) * BLOCK_SIDE_LENGTH
        new_qodot.translation.z = (len(map_to_node) / BLOCKS_PER_ROW) * BLOCK_SIDE_LENGTH
            
        # Update the Inverse Scale Factor
        new_qodot.inverse_scale_factor = BLOCK_INVERSE_SCALE
        
        # Give it the path to the map
        new_qodot.map_file = ProjectSettings.globalize_path(in_path)
        
        # Finally, stick it in the dictionary
        map_to_node[in_path] = new_qodot

    # Okay, so the QodotMap node definitely exists. Time to build that sucker!
    map_to_node[in_path].verify_and_build()
    
    # Tell anyone who's listening that we finished building a block. 
    emit_signal(
        "block_built", # signal type/name
        in_path, # Godot Path
        map_to_node[in_path].map_file, # Real Path
        map_to_node[in_path].translation, # Local Position
        map_to_node[in_path].global_transform.origin # Global Position.
    )
    
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

func get_random_map():
    var index = randi() % len(map_to_node.keys())
    return map_to_node.keys()[index]
