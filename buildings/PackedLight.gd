extends Node

# Enums for controlling which group a light is in. 
enum LightGroups {
      ONE = 0x00000,
      TWO = 0x00001,
    THREE = 0x00002,
     FOUR = 0x00003,
}
# Mask for getting and setting the above values.
const LIGHT_GROUP_MASK = LightGroups.FOUR;

# The range of this light. 7 Bits, meaning value caps out at 127. By default
# this is in world units, though the shader options may change that.
const RANGE_MASK = 0x001FC;
# The shift required to get the real value from the masked-out value
const RANGE_SHIFT = 2;
# What's the maximum value for the RANGE?
const RANGE_MAX = RANGE_MASK >> RANGE_SHIFT;

# The position of the each light on Y, as shifted away from the origin. The
# lights are mirrored to each of the four corners. 5 Bits, meaning value caps
# out at 32. By default this is in world units, though the shader options may
# change that.
const POS_X_MASK = 0x03E00;
# The shift required to get the real value from the masked-out value
const POS_X_SHIFT = 9;
# What's the maximum value for POS X?
const POS_X_MAX = POS_X_MASK >> POS_X_SHIFT;

# The position of the each light on Y, as shifted away from the origin. The
# lights are mirrored to each of the four corners. 5 Bits, meaning value caps
# out at 32. By default this is in world units, though the shader options may
# change that.
const POS_Y_MASK = 0x7C000;
# The shift required to get the real value from the masked-out value
const POS_Y_SHIFT = 14;
# What's the maximum value for POS Y?
const POS_Y_MAX = POS_Y_MASK >> POS_Y_SHIFT;

# Class for packing light options into a float between 0 and 1
class PackedLight:
    # What group is this light in?
    var group = LightGroups.ONE
    # What's the range of this light?
    var range_val = 0
    # What's the shift from origin for this light on X?
    var pos_x = 0
    # What's the shift from origin for this light on Y?
    var pos_y = 0
    
    func set_group(new_group):
        group = clamp(int(new_group), LightGroups.ONE, LightGroups.FOUR)

    func set_range(new_range):
        range_val = clamp(int(new_range), 0, RANGE_MAX)
        
    func set_pos_x(new_pos):
        pos_x = clamp(int(new_pos), 0, POS_X_MAX)
    
    func set_pos_y(new_pos):
        pos_y = clamp(int(new_pos), 0, POS_Y_MAX)
    
    func to_int():
        # Set the group
        var int_val = 0 | group
        
        # Pack in the range, x shift, and y shift
        int_val |= (range_val << RANGE_SHIFT)
        int_val |= (pos_x << POS_X_SHIFT)
        int_val |= (pos_y << POS_Y_SHIFT)
        
        # Return the integer value
        return int_val
    
    func from_int(in_val):
        # Now unpack the values
        group = in_val & LIGHT_GROUP_MASK
        range_val = (in_val & RANGE_MASK) >> RANGE_SHIFT
        pos_x = (in_val & POS_X_MASK) >> POS_X_SHIFT
        pos_y = (in_val & POS_Y_MASK) >> POS_Y_SHIFT
    
    # Packs all of this light information into a float between 0 and 1.
    func to_zero_one_float():
        # Divide the int by one million. This should stick six figures onto the
        # end of the float - that means we can pass this value through a
        # clamp(x, 0, 1) call without problems.
        return float(to_int()) / 1000000.0
    
    # Unpacks all of this light information from a float between 0 and 1.
    func from_zero_one_float(in_val):
        # Convert the float to an actual int and process it
        var int_val = from_int( int(in_val * 1000000.0) )
        # All done!
