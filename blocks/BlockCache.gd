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

# How much do we shift on a particular axis whenever we shift a block?
const SHIFT_FACTOR = 1024

enum {
    OUTSIDE_ENTITY = 1, 
    INSIDE_ENTITY = 2,
    INSIDE_BRUSH = 3
}

# Fires every time a block is built. Gives the godot file path (i.e. user:// or
# res://), the real file path (i.e. /home/developer/...), as well as the local
# and global positions. Not really that necessary, but useful for debuggery and
# similar situations.
signal block_built(godot_path, real_path, local_pos, global_pos)

# Here's where we'll stick the QodotMaps once we've built them - it what we'll
# use to quickly get info from the node.
var map_to_node = {}

# Gets a list of all the .map files in our dedicated TrenchBroom map directory.
func get_all_resource_maps():
    # Create a blank file pointer - we need this to test whether files exist or
    # not.
    var existence_checker = File.new()

    # Now - we need to dynamically build up our list of blocks we can use. To do
    # so, we're gonna take a look at the blocks directory and see what we can
    # do.
    var dir = Directory.new()
    
    # Here's where we'll stick the list of maps-to-build.
    var map_list = []
    
    # If the directory didn't open, then we can't really do anything at all.
    # Ergo, we'll have to back out.
    if dir.open(IN_MAP_PATH) != OK:
        printerr("Couldn't load TrenchBroom Maps directory! Can't do anything!!!")
        return map_list
    
    # Start the directory-listing-processing thing.
    dir.list_dir_begin(true)
    
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
        
        # Stick the full path in our map list!
        map_list.append(IN_MAP_PATH + file_name)
            
        # Now that we've made the derivatives and built the block, get the next
        # block-map-file.
        file_name = dir.get_next()
    
    # Finish off the directory listing processing... thing.
    dir.list_dir_end()
    
    # Return 0
    return map_list

func make_blockenstein(map_arr):
    # How many entities do we have? This is VITAL for ensuring the world blocks
    # are grouped together appropriately.
    var entity_count = 1
    # How many groups/blocks do we have? This doesn't matter as much, more of a
    # nice-to-have.
    var group_count = 0
    
    var group_shift
    
    var map_entities = [
        { "classname": "worldspawn", "_tb_textures": "textures"}
    ]

    # ~~~~~~~~~~~~~
    #
    # Step 1: Read in from all of our maps and translate their entities into a
    #         dictionary-based pseudoblock structure.
    # 
    # ~~~~~~~~~~~~~
    for map_path in map_arr:
        var entity_list = quake_map_to_entity_list(map_path)
        
        var filename = map_path.get_file()
        
        var curr_group = {}
        curr_group["classname"] = "func_group"
        curr_group["_tb_name"] = str(group_count) + "::" + filename
        curr_group["_tb_type"] = "_tb_group"
        curr_group["_tb_id"] = str(entity_count)
        curr_group["brushes"] = []
        
        # Stick the group in our map entities list.
        map_entities.append(curr_group)
        
        # That's an entity in the stack, even if it's only a group. Increment the
        # count!
        entity_count += 1
        
        # Calculate the shift on X.
        group_shift = SHIFT_FACTOR * group_count
        
        # Capture the current entity count before we start processing
        var entity_start_count = entity_count
        
        # Right - now that we've gotten the new list of entities, we need to put
        # them together into a single map.
        for entity in entity_list:
            # For each of these entities brushes...
            for brush in entity["brushes"]:
                # For each face in this brush...
                for face in brush:
                    # Shift over the vertices
                    face["vertex1"] += Vector3(group_shift, 0, 0)
                    face["vertex2"] += Vector3(group_shift, 0, 0)
                    face["vertex3"] += Vector3(group_shift, 0, 0)
                    
            # If this is the map's worldspawn...
            if entity["classname"] == "worldspawn":
                # First, iterate through each texture collection name in the
                # worldspawn. For each such texture collection string...
                for tex_collection in entity["_tb_textures"].split(";"):
                    # If it's already in the existing texture list, skip it.
                    if tex_collection in map_entities[0]["_tb_textures"]:
                        continue
                    # Otherwise, add it in!
                    map_entities[0]["_tb_textures"] += ";" + tex_collection
        
                # Now we're going to try and step through all of the entity's
                # keys and move just the user-added ones to the group entity
                for key in entity:
                    # If this is one of the default keys, or something we added,
                    # skip it!
                    if key in ["classname", "_tb_textures", "brushes"]:
                        continue
                    # Otherwise, it's good. Stick it in!
                    curr_group[key] = entity[key]
            
            # If this entity is a func_group OR just worldspawn...
            if entity["classname"] in ["func_group", "worldspawn"]:
                # Then we're just here for the brushes. Stick them in our current
                # group.
                curr_group["brushes"] += entity["brushes"]
                # Then we're all good here. Skip!
                continue
            
            # Set this entity's _tb_group
            entity["_tb_group"] = curr_group["_tb_id"]
        
            # Stick that entity in our map entities list.
            map_entities.append(entity)
        
            # Increment our entity count
            entity_count += 1
        
        # That's a valid group. Increment the group count!
        group_count += 1

    # ~~~~~~~~~~~~~
    #
    # Step 2: Write out all of those entities to a new map.
    # 
    # ~~~~~~~~~~~~~
    # Alright, now to print this out.
    var out_map = File.new()
    out_map.open(OUT_MAP_PATH + "blockenstein.map", File.WRITE)

    # Write out the game name and the format
    out_map.store_line("// Game: Neon City Generator 2.0\n// Format: Standard\n")

    # Now, for each entity we have...
    for entity in map_entities:
        # Initial "{"
        out_map.store_line("{")
        
        # First, write out all of the keys (except the brushes, which we made up)
        for key in entity:
            if key == "brushes":
                continue
            out_map.store_line( "\"%s\" \"%s\"" % [ key, entity[key] ] )
        
        # If this entity doesn't have brushes, then close it out.
        if not "brushes" in entity:
            # Closing "}"
            out_map.store_line("}")
            continue
        
        # Now, for each brush...
        for brush in entity["brushes"]:
            # Initial "{"
            out_map.store_line("{")
            
            # For each face, convert it to Quake format and write it out
            for face in brush:
                out_map.store_line( face_dict_to_line(face))
            
            # Closing "}"
            out_map.store_line("}")
        
        # Closing "}"
        out_map.store_line("}")

    out_map.close()

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

func dict_from_face_line(in_line):
    # We'll stick the face lines into this return-dictionary.
    var retd = {}
    
    # Okay, remove any parentheses from our line and then split it using any
    # spaces as a delimiter.
    var toks = in_line.replace('(','').replace(')','').split(" ", false)
    
    # Next, take those values and slot them in to our return dictionary
    retd["vertex1"] = Vector3( float(toks[0]), float(toks[1]), float(toks[2]) )
    retd["vertex2"] = Vector3( float(toks[3]), float(toks[4]), float(toks[5]) )
    retd["vertex3"] = Vector3( float(toks[6]), float(toks[7]), float(toks[8]) )
    
    retd["texture"]  = toks[9]
    retd["offset"] = Vector2( float(toks[10]), float(toks[11]) )
    retd["rotation"] = toks[12]
    retd["scale"] = Vector2( float(toks[13]), float(toks[14]) )
    
    return retd

func face_dict_to_line(face_dict):
    # The string that we'll use to format out the face-line
    var format
    
    format = "( %s %s %s ) ( %s %s %s ) ( %s %s %s ) "
    format += "%s %s %s %s %s %s"
    
    return format % [ face_dict["vertex1"].x,
        face_dict["vertex1"].y, face_dict["vertex1"].z,
        face_dict["vertex2"].x, face_dict["vertex2"].y, face_dict["vertex2"].z,
        face_dict["vertex3"].x, face_dict["vertex3"].y, face_dict["vertex3"].z,
        face_dict["texture"], face_dict["offset"].x, face_dict["offset"].y,
        face_dict["rotation"], face_dict["scale"].x, face_dict["scale"].y,
    ]

func quake_map_to_entity_list(map_path):
    var state = OUTSIDE_ENTITY
    var entity_list = []

    var current_entity = null
    var current_brush = null

    var in_map = File.new()
    in_map.open(map_path, File.READ)
    
    while not in_map.eof_reached():
        # First, get the line and then filter it down.
        var line = in_map.get_line().strip_escapes()
        
        # Okay - how we process this line depends on our current state.
        match state:
            OUTSIDE_ENTITY:
                # If we've encountered a section-opener...
                if "{" == line:
                    # We've entered a new entity! Create an entity dictionary.
                    entity_list.append({})
                    # Create the entity's Brushes
                    entity_list[-1]["brushes"] = []
                    
                    # Point our 'current' entity at the entity we just made
                    current_entity = entity_list[-1]
                    
                    # Finally, mark that we're in an entity
                    state = INSIDE_ENTITY
            INSIDE_ENTITY:
                # If we've encountered a section-opener...
                if "{" == line:
                    # Then it has to be a brush! Add a brush to the current stack.
                    current_entity["brushes"].append([])
                    
                    # Point our 'current' brush at the brush we just made
                    current_brush = current_entity["brushes"][-1]
                    
                    # We're now inside a brush!
                    state = INSIDE_BRUSH
                    
                # Otherwise, if we've encountered a section-closer...
                elif "}" == line:
                    # Okay, then this entity is closing out. We're now outside the
                    # entity.
                    state = OUTSIDE_ENTITY
                    
                    # We don't have a current entity anymore
                    current_entity = null
                    
                # Otherwise, if this line starts with a ", then this is an entity
                # key/value
                elif "\"" == line[0]:
                    # Split into two fragments, based on the gap between key and
                    # value
                    var kv_list = line.split("\" \"")
                    # Remove any ancillary/remaining " characters from the key
                    # and/or value.
                    var ent_key = kv_list[0].replace("\"", "")
                    var ent_val = kv_list[1].replace("\"", "")
                    
                    # So long as the ent key isn't our brushes, we can then
                    # comfortably stick it in 
                    if ent_key != "brushes":
                        current_entity[ent_key] = ent_val
            INSIDE_BRUSH:
                # If we've encountered a section-closer...
                if "}" == line:
                    # Okay, then this brush is closing out. We're now inside the
                    # entity.
                    state = INSIDE_ENTITY
                    # We don't have a current brush anymore
                    current_brush = null
                # Otherwise, so long as this line isn't a comment line...
                elif line.substr(0, 2) != "//":
                    # Then process the current line into a dictionary and then add
                    # it to the brush array
                    current_brush.append( dict_from_face_line(line) )
            _:
                print("Stuck in invalid state - ", state)
                
    in_map.close()
                
    # Okay, throw back the entity list!
    return entity_list

func get_random_map():
    var index = randi() % len(map_to_node.keys())
    return map_to_node.keys()[index]
