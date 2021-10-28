#!/usr/bin/python3
import enum
import sys
import os

class ProcessState(enum.IntEnum):
    OUTSIDE_ENTITY = 1
    INSIDE_ENTITY = 2
    INSIDE_BRUSH = 3

# Approximation of the Godot Vector2 class
class GDVector2:

    def __init__(self, x, y):
        self.x = x
        self.y = y
    
    # In order to change the values of this Vector, yet maintain the percision 
    # of the float (not exactly a Pythonic specialty), we need to use this
    # special and overly complicated function to change the strings around.
    def shift(self, x_shift, y_shift):
        x_precision = self.x.split('.')
        if len(x_precision) > 1:
            x_precision = len(x_precision[1])
        else:
            x_precision = 0
        
        y_precision = self.y.split('.')
        if len( y_precision ) > 1:
            y_precision = len( y_precision[1] )
        else:
            y_precision = 0
        
        x_format_str = "{:-." + str(x_precision) + "f}"
        y_format_str = "{:-." + str(y_precision) + "f}"
        
        self.x = x_format_str.format( float(self.x) + x_shift )
        self.y = y_format_str.format( float(self.y) + y_shift )
        
# Approximation of the Godot Vector3 class
class GDVector3:

    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z

    # In order to change the values of this Vector, yet maintain the percision 
    # of the float (not exactly a Pythonic specialty), we need to use this
    # special and overly complicated function to change the strings around.
    def shift(self, x_shift, y_shift, z_shift):
        x_precision = self.x.split('.')
        if len(x_precision) > 1:
            x_precision = len(x_precision[1])
        else:
            x_precision = 0
        
        y_precision = self.y.split('.')
        if len( y_precision ) > 1:
            y_precision = len( y_precision[1] )
        else:
            y_precision = 0

        z_precision = self.z.split('.')
        if len( z_precision ) > 1:
            z_precision = len( z_precision[1] )
        else:
            z_precision = 0
        
        x_format_str = "{:-." + str(x_precision) + "f}"
        y_format_str = "{:-." + str(y_precision) + "f}"
        z_format_str = "{:-." + str(z_precision) + "f}"
        
        self.x = x_format_str.format( float(self.x) + x_shift )
        self.y = y_format_str.format( float(self.y) + y_shift )
        self.z = z_format_str.format( float(self.z) + z_shift )

def dict_from_face_line(line):
    # Create a dictionary to store the values in
    ret = {}
    
    # First, remove any parenthesis
    toks = line.replace('(', '')
    toks = toks.replace(')', '')
    # Remove any new lines
    toks = toks.replace('\n', '')
    # Split into tokens based on whitespace
    toks = toks.split(' ')
    # Filter out any empty strings from the list of tokens
    toks = list(filter(None, toks))
    
    ret["vertex1"] = GDVector3( toks[0], toks[1], toks[2] )
    ret["vertex2"] = GDVector3( toks[3], toks[4], toks[5] )
    ret["vertex3"] = GDVector3( toks[6], toks[7], toks[8] )
    
    ret["texture"]  = toks[9]
    ret["offset"] = GDVector2( toks[10], toks[11] )
    ret["rotation"] = toks[12]
    ret["scale"] = GDVector2( toks[13], toks[14] )
    
    return ret

def face_dict_to_line(face_dict):
    ret = "( {vertex1.x} {vertex1.y} {vertex1.z} ) "
    ret += "( {vertex2.x} {vertex2.y} {vertex2.z} ) "
    ret += "( {vertex3.x} {vertex3.y} {vertex3.z} ) "
    ret += "{texture} {offset.x} {offset.y} "
    ret += "{rotation} {scale.x} {scale.y}"
    
    return ret.format(**face_dict)

def file_to_entity_list(file_path):
    state = ProcessState.OUTSIDE_ENTITY
    entity_list = []

    current_entity = None
    current_brush = None

    f = open(file_path)
    for line in f:
        # Okay - how we process this line depends on our current state. We'll
        # use a series of if statements since Python has no switch statment.
        
        #
        # Outside an entity
        #
        if state == ProcessState.OUTSIDE_ENTITY:
            # If we've encountered a section-opener...
            if "{\n" == line:
                # We've entered a new entity! Create an entity dictionary.
                entity_list.append({})
                # Create the entity's Brushes
                entity_list[-1]["brushes"] = []
                
                # Point our 'current' entity at the entity we just made
                current_entity = entity_list[-1]
                
                # Finally, mark that we're in an entity
                state = ProcessState.INSIDE_ENTITY
        
        #
        # Inside an entity
        #
        elif state == ProcessState.INSIDE_ENTITY:
            # If we've encountered a section-opener...
            if "{\n" == line:
                # Then it has to be a brush! Add a brush to the current stack.
                current_entity["brushes"].append([])
                
                # Point our 'current' brush at the brush we just made
                current_brush = current_entity["brushes"][-1]
                
                # We're now inside a brush!
                state = ProcessState.INSIDE_BRUSH
                
            # Otherwise, if we've encountered a section-closer...
            elif "}\n" == line:
                # Okay, then this entity is closing out. We're now outside the
                # entity.
                state = ProcessState.OUTSIDE_ENTITY
                
                # We don't have a current entity anymore
                current_entity = None
                
            # Otherwise, if this line starts with a ", then this is an entity
            # key/value
            elif "\"" == line[0]:
                # Split into two fragments, based on the gap between key and
                # value
                kv_list = line.split("\" \"")
                # Remove any ancillary/remaining " characters from the key
                # and/or value. Also, get rid of any possible \n characters
                # because somehow those are also finding their way in?????
                ent_key = kv_list[0].replace("\"", "").replace('\n', '')
                ent_val = kv_list[1].replace("\"", "").replace('\n', '')
                
                # So long as the ent key isn't our brushes, we can then
                # comfortably stick it in 
                if ent_key != "brushes":
                    current_entity[ent_key] = ent_val

        #
        # Inside a brush
        #
        elif state == ProcessState.INSIDE_BRUSH:
            # If we've encountered a section-closer...
            if "}\n" == line:
                # Okay, then this brush is closing out. We're now inside the
                # entity.
                state = ProcessState.INSIDE_ENTITY
                # We don't have a current brush anymore
                current_brush = None
            # Otherwise, so long as this line isn't a comment line...
            elif line[:2] != "//":
                # Then process the current line into a dictionary and then add
                # it to the brush array
                current_brush.append( dict_from_face_line(line) )
                
    # Okay, throw back the entity list!
    return entity_list

#
# SCRIPT START!
#

print("Received ", len(sys.argv), " arguments for processing.")

if len(sys.argv) <= 1:
    print("No actual maps received! Aborting!")
    sys.exit()

group_count = 0
entity_count = 1
brush_count = 0

# How much do we shift on a particular axis whenever we shift a block?
SHIFT_FACTOR = 1024

map_entities = [
    {
        "classname": "worldspawn",
        "_tb_textures": "textures"
    }
]

for map_path in sys.argv[1:]:
    print(map_path)
    entity_list = file_to_entity_list(map_path)
    
    _, filename = os.path.split(map_path)
    
    curr_group = {}
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
    entity_start_count = entity_count
    
    # Right - now that we've gotten the new list of entities, we need to put
    # them together into a single map.
    for entity in entity_list:
        # For each of these entities brushes...
        for brush in entity["brushes"]:
            # For each face in this brush...
            for face in brush:
                # Shift over the vertices
                face["vertex1"].shift(group_shift, 0, 0)
                face["vertex2"].shift(group_shift, 0, 0)
                face["vertex3"].shift(group_shift, 0, 0)
                
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
    
            # Now we're going to try and step through all of the entity's keys
            # and move just the user-added ones to the group entity
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

#
# File write-out
#

# Alright, now to print this out.
f = open("out_map.map", "w")

# Write out the game name and the format
f.write("// Game: Neon City Generator 2.0\n// Format: Standard\n")

# Now, for each entity we have...
for entity in map_entities:
    # Initial "{"
    f.write("{\n")
    
    # First, write out all of the keys (except the brushes, which we made up)
    for key in entity:
        if key == "brushes":
            continue
        f.write( "\"{:s}\" \"{:s}\"\n".format(key, entity[key]) )
    
    # If this entity doesn't have brushes, then close it out.
    if not "brushes" in entity:
        # Closing "}"
        f.write("}\n")
        continue
    
    # Now, for each brush...
    for brush in entity["brushes"]:
        # Initial "{"
        f.write("{\n")
        
        # For each face, convert it to Quake format and write it out
        for face in brush:
            f.write( face_dict_to_line(face) + "\n" )
        
        # Closing "}"
        f.write("}\n")
    
    # Closing "}"
    f.write("}\n")

f.close()
