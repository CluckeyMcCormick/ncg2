#!/usr/bin/python3
import enum

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

state = ProcessState.OUTSIDE_ENTITY
current_brush = None

f = open("../../blocks/trenchbroom_maps/s01_block07.map")
for line in f:
    # If this line is a start or end bracket...
    if "{\n" == line or "}\n" == line:
        # Then we're in a state change. 
        state += line.count('{')
        state -= line.count('}')
        # Clamp the state.
        state = min(ProcessState.INSIDE_BRUSH, state)
        state = max(ProcessState.OUTSIDE_ENTITY, state)
        
        state_name = list(ProcessState)[state - 1].name
        #print("\tNew State: ", state_name)
        
        current_brush = None
    elif line[0] == "(" and state == ProcessState.INSIDE_BRUSH:
        face_dict = dict_from_face_line(line)
        face_dict["vertex3"].shift(1000, 1000, 1000)
        face_dict["offset"].shift(1000, 1000)
        print(face_dict_to_line( face_dict ))
    else:
        state_name = list(ProcessState)[state - 1].name
        
