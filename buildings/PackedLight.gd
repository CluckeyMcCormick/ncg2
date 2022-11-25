extends Node

# Enums for controlling which group a light is in. 
enum LightGroups {
      ONE = 1,
      TWO = 2,
    THREE = 3,
     FOUR = 4,
}
const LIGHT_GROUP_PACK_FACTOR = 100

# What's the maximum value for the RANGE?
const RANGE_MAX = 999
const RANGE_PACK_FACTOR = 1000

# Class for packing light options into a float between 0 and 1
class PackedLight:
    # What group is this light in?
    var group = LightGroups.ONE
    # What's the range of this light?
    var range_val = 0
    
    func set_group(new_group):
        group = clamp( int(new_group), LightGroups.ONE, LightGroups.FOUR )
    
    func set_range(new_range):
        range_val = clamp(int(new_range), 0, RANGE_MAX)
    
    func to_range_float():
        # Return the range and group value-packed as a 0 to 1 float
        return range_val / float(RANGE_PACK_FACTOR)
    
    func from_range_float(in_val):
        # Unpack the range
        self.range_val = int(in_val * RANGE_PACK_FACTOR) % RANGE_PACK_FACTOR
    
    func to_southern_group_float():
        # Return the group, reduced to 0.0x - add .0001 though! We've had
        # floating point errors even when a value is just 0.xx, so we'll add a
        # padding 0 and a useless digit (i.e. two MORE significant figures) so
        # the part we want to preserve is preserved! 
        return group / float(LIGHT_GROUP_PACK_FACTOR) + 0.0001
    
    func to_northern_group_float():
        # Return the group, reduced to 0.x - add .0001 though! We've had
        # floating point errors even when a value is just 0.xx, so we'll add a
        # padding 0 and a useless digit (i.e. two MORE significant figures) so
        # the part we want to preserve is preserved! 
        return (group * 10) / float(LIGHT_GROUP_PACK_FACTOR) + 0.0001

    func from_southern_group_float(in_val):
        group =  int(in_val * LIGHT_GROUP_PACK_FACTOR) % 10
    
    func from_northern_group_float(in_val):
        group = int((in_val * LIGHT_GROUP_PACK_FACTOR) / 10.0) % 10
        
