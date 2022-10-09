
# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# For some types of values, we need to break them out into a dictionary that can
# then be stored in a dictionary.
const VALUE_TYPE_KEY = "json_value_type"

# Save to a given dictionary to a given path
static func save_dict(path, save_me):
    # Create the candidate dictionary - this is what we'll actually save
    var candidate = {}
    
    # Create a new file so we can actually save the user's profile
    var file = File.new()
    
    # Error value to make sure everything works ok
    var err = OK
    
    # If the user didn't give us a dictionary to save, back out!
    if not save_me is Dictionary:
        printerr("Cannot save non-Dictionary object!")
        return false
    
    # Okay - grab that dictionary!
    candidate = json_expand(save_me)
    
    # Now it's time to save - open the file!
    err = file.open( path, File.WRITE )
    
    # If there was an error...
    if err:  
        # Tell the user.
        printerr(
            "Experienced an error opening [%s], error coe is %d." % \
            [ path, err ]
        )
        # Back out
        return false
    
    # Otherwise, we're all good. Yay!
    # Get the JSON text and store it in the file
    file.store_line( JSON.print(candidate, "    ", true) )
        
    # Close it out
    file.close()
    
    # We're done! Return true
    return true

static func load_dict(path):
    # To load a dictionary, we'll need a file object
    var file = File.new()
    
    # This is the dictonary we'll load into and return
    var ret_dict = {}
    
    # Error from opening the file
    var err
    
    # Open the file
    err = file.open(path, File.READ)
    
    # If we had an error, back out!
    if err:
        printerr("Couldn't load dictionary JSON at %s!" % [path])
        return ret_dict
    
    # Get the text out and parse it
    ret_dict = parse_json( file.get_as_text() )
    
    # Close the file - we're done with it!
    file.close()
    
    # Crush the dictionary down into a Godot Dictionary
    ret_dict = json_crush(ret_dict)
    
    # Return our dictionary
    return ret_dict

static func json_expand(in_value):
    # What value will we return?
    var ret = null
    
    # What's our current value we're working with? We need this for arrays and
    # dicts
    var curr
    
    # Check the type of the current key 
    match typeof( in_value ):
        
        # These types are JSON compatible so we can save those directly
        TYPE_BOOL, TYPE_REAL, TYPE_STRING:
            ret = in_value
        
        # For an array, we'll need to go over the elements and do do expansion
        # processing on all of them.
        TYPE_ARRAY:
            ret = []
            
            # For each element in the array...
            for element_value in in_value:
                # Expand the current value
                curr = json_expand(element_value)
                
                # If we got a valid value, append it to the array
                if curr != null:
                    ret.append(curr)
                
                # Otherwise, something went wrong. Tell the user!
                else:
                    printerr(
                        "Invalid expand value [%s] [type: %d] in Array! " +
                        " Discarding value..." % \
                        [ element_value, typeof(element_value) ]
                    )
        
        # For a dictionary, we'll need to go over the keys and do expansion
        # processing on all of them
        TYPE_DICTIONARY:
            ret = {}
            
            # For each key in the dict...
            for key in in_value:
                # Break out the current key
                curr = json_expand(in_value[key])
                
                # If we got a valid value, stick it in the dictionary
                if curr != null:
                    ret[key] = curr
                
                # Otherwise, something went wrong. Tell the user!
                else:
                    printerr(
                        "Invalid expand value [%s] [type: %d] in Dictionary" +
                        " for key %s! Discarding value..." % \
                        [ in_value[key], typeof(in_value[key]), key ]
                    )
        
        # Save the int as a dictionary
        TYPE_INT:
            ret = {
                VALUE_TYPE_KEY: TYPE_INT,
                "int": in_value
            }
        
        # Save the color as hex-code
        TYPE_COLOR:
            ret = {
                VALUE_TYPE_KEY: TYPE_COLOR,
                "value": in_value.to_html()
            }
        
        # Save the vector as a X and Y dict
        TYPE_VECTOR2:
            ret = {
                VALUE_TYPE_KEY: TYPE_VECTOR2,
                "x": in_value.x,
                "y": in_value.y
            }
        
        # Save the vector as a X, Y, and Z dict
        TYPE_VECTOR3:
            ret = {
                VALUE_TYPE_KEY: TYPE_VECTOR3,
                "x": in_value.x,
                "y": in_value.y,
                "z": in_value.z
            }
        
        # Incompatible value!!!
        _:
            # Skip it!
            pass
    
    return ret

static func json_crush(in_value):
    # What value will we return?
    var ret = null
    
    # What's our current value we're working with? We need this for arrays and
    # dicts
    var curr
    
    # Check the type of the current key 
    match typeof( in_value ):
        
        # These types are JSON compatible so we can save those directly
        TYPE_BOOL, TYPE_REAL, TYPE_STRING:
            ret = in_value
        
        TYPE_ARRAY:
            ret = []
            # For each element in the array...
            for element_value in in_value:
                # Crush the current value and append it to the array
                ret.append( json_crush(element_value) )
        
        TYPE_DICTIONARY:
            ret = {}
            
            # If this dictionary lacks a VALUE_TYPE_KEY, then it's not an
            # expanded datatype, so...
            if not VALUE_TYPE_KEY in in_value:
                # This is just a regular old dictionary! So, for each key in the
                # dictionary...
                for key in in_value:
                    # Crush the current key
                    ret[key] = json_crush(in_value[key])
            
            # Otherwise...
            else:
                # This is a JSON-expansion type. JSON only supports floats, so
                # look at the VALUE_TYPE_KEY as an int.
                match int(in_value[VALUE_TYPE_KEY]):
                    # It's an int!
                    TYPE_INT:
                        ret = int( in_value["int"] )
                    
                    # It's a color!
                    TYPE_COLOR:
                        ret = Color( in_value["value"] )
                    
                    # It's a Vector2!
                    TYPE_VECTOR2:
                        ret = Vector2( in_value["x"], in_value["y"] )
                    
                    # It's a Vector3!
                    TYPE_VECTOR3:
                        ret = Vector3(
                            in_value["x"], in_value["y"], in_value["z"]
                        )
                    
                    # I... don't know what that is! It's a mistake, is what it
                    # is!
                    _:
                        # Tell the user
                        printerr(
                            "Invalid crush type value [%d] for in Dictionary !" %
                            [ int(in_value[VALUE_TYPE_KEY]) ]
                        )
                        # Just boil it down to nothing
                        ret = null
    
    return ret
