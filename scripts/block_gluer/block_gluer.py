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
        
# Approximation of the Godot Vector3 class
class GDVector3:

    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z

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

f = open("inspection_sample.map")
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
    	print(face_dict_to_line( dict_from_face_line(line) ))
    else:
        state_name = list(ProcessState)[state - 1].name
        
