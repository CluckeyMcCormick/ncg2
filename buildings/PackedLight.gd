extends Node

# Enums for controlling which group a light is in. 
enum LightGroups {
      ONE = 1,
      TWO = 2,
    THREE = 3,
     FOUR = 4,
}
# Mask for getting and setting the above values.
const LIGHT_GROUP_MASK = LightGroups.FOUR;

# The range of this light. 8 Bits, meaning value caps out at 255. By default
# this is in world units, though the shader options may change that. We have
# four possible light positions (SouthEast, NorthEast, NorthWest, SouthWest) and
# each one has a unique mask.
const RANGE_SE_MASK = 0x00FF;
const RANGE_NE_MASK = 0xFF00;
const RANGE_NW_MASK = 0xFF00;
const RANGE_SW_MASK = 0x00FF;
# How many bits are allocated to range?
const RANGE_WIDTH = 8;
# What's the maximum value for the RANGE?
const RANGE_MAX = RANGE_SW_MASK;

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
    
    func to_compressed_group():
        # Return the group value as a 0 to 1 float
        return group / float(len(LightGroups))
    
    func from_compressed_group(in_val):
        # Now unpack the values
        group = float( round( in_val * len(LightGroups) ) )
    
    func to_southeast_range_int():
        return range_val

    func to_northeast_range_int():
        return (range_val << RANGE_WIDTH);

    func to_northwest_range_int():
        return (range_val << RANGE_WIDTH);

    func to_southwest_range_int():
        return range_val


    func from_southeast_range_int(int_val):
        range_val = int_val & RANGE_SE_MASK;

    func from_northeast_range_int(int_val):
        range_val = (int_val & RANGE_NE_MASK) >> RANGE_WIDTH;

    func from_northwest_range_int(int_val):
        range_val = (int_val & RANGE_NW_MASK) >> RANGE_WIDTH;

    func from_southwest_range_int(int_val):
        range_val = int_val & RANGE_SW_MASK;
    
# Process an int so it can be passed into the shader as a float
static func float_compress(int_val):
    # Divide the int by one hundred thousand. This should stick five figures
    # onto the end of the float - that means we can pass this value through
    # a clamp(x, 0, 1) call without problems. This should also be large
    # enough to avoid floating point errors.
    return stepify(float(int_val) / 100000.0, 0.000001 )

# Process a float, return an int that can be bit-masked
static func float_decompress(float_val):
    # Multiply by one hundred thousand, convert to an int, and return it.
    return int(round(float_val * stepify(100000.0, 0.000001)))
    # All done!
