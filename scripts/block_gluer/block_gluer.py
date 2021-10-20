#!/usr/bin/python3
import enum

class ProcessState(enum.IntEnum):
    OUTSIDE_ENTITY = 1
    INSIDE_ENTITY = 2
    INSIDE_BRUSH = 3

state = ProcessState.OUTSIDE_ENTITY

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
        print("\tNew State: ", state_name)
    else:
        state_name = list(ProcessState)[state - 1].name
        print(state_name)
    
    #print(line, end='')
