
# For some types of values, we need to break them out into a dictionary that can
# then be stored in a dictionary.
const VALUE_TYPE_KEY = "value_type"

# Save to a given dictionary to a given path
static func save_dict(path, save_me):
    # Get the candidate dictionary
    var candidate = {}
    
    # Create a new file so we can actually save the user's profile
    var file = File.new()
    
    # Error value to make sure everything works ok
    var err = OK
    
    # If the user didn't give us a dictionary to save, back out!
    if not save_me is Dictionary:
        printerr("Cannot save non-Dictionary object!")
        return false
    
    # For each key...
    for key in save_me:
        # Check the type of the current key 
        match typeof( save_me[key] ):
            # TODO: We "break out" colors and vectors into dictionaries - maybe
            # we should go over arrays and dictionaries and "break out" values
            # in those? It'd be easy to do but it'd have the potential to loop
            # infinitely. I think it's a good idea; it just doesn't have a lot
            # of value right now.
            
            # These types are JSON compatible so we can save those directly
            TYPE_BOOL, TYPE_INT, TYPE_REAL, TYPE_STRING, TYPE_ARRAY, TYPE_DICTIONARY:
                candidate[key] = save_me[key]
            
            # Save the color as hex-code
            TYPE_COLOR:
                candidate[key] = {
                    VALUE_TYPE_KEY: TYPE_COLOR,
                    "value": save_me[key].to_html()
                }
            
            # Save the vector as a X and Y dict
            TYPE_VECTOR2:
                candidate[key] = {
                    VALUE_TYPE_KEY: TYPE_VECTOR2,
                    "x": save_me[key].x,
                    "y": save_me[key].y
                }
            
            # Save the vector as a X, Y, and Z dict
            TYPE_VECTOR3:
                candidate[key] = {
                    VALUE_TYPE_KEY: TYPE_VECTOR3,
                    "x": save_me[key].x,
                    "y": save_me[key].y,
                    "z": save_me[key].z
                }
            
            # Incompatible value!!!
            _:
                printerr(
                    "Invalid value type [%s] for key %s!" %
                    [ save_me[key], key ]
                )
    
    # Alright, the candidate dictionary is full of JSON-compatabile goodies. Now
    # we just gotta save it.
    
    # Open the file!
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
    
    # Now, for each key in the dictionary...
    for key in ret_dict:
        
        # If the value here is not a dictionary...
        if not ret_dict[key] is Dictionary:
            # Skip it!
            continue
        
        # Okay, so this is a dictionary. If this dictionary lacks a
        # VALUE_TYPE_KEY, then it's not a broken-out/devolved datatype, so...
        if not VALUE_TYPE_KEY in ret_dict[key]:
            # Skip it!
            continue
        
        # Okay, so this is a dictionary and it's for-sure a devolved datatype,
        # then we need different processing depending on the VALUE_TYPE_KEY.
        # Note that this is wrapped in an int
        match int(ret_dict[key][VALUE_TYPE_KEY]):
            # Load the color using the hex value
            TYPE_COLOR:
                ret_dict[key] = Color( ret_dict[key]["value"] )
            
            # Load the vector using the X/Y
            TYPE_VECTOR2:
                ret_dict[key] = Vector2(
                    ret_dict[key]["x"],
                    ret_dict[key]["y"]
                )
            
            # Load the vector using the X/Y/Z
            TYPE_VECTOR3:
                ret_dict[key] = Vector3(
                    ret_dict[key]["x"],
                    ret_dict[key]["y"],
                    ret_dict[key]["z"]
                )
            
            # Incompatible value!!!
            _:
                printerr(
                    "Invalid value type %s in JSON for key %s !" %
                    [ ret_dict[key][VALUE_TYPE_KEY], key ]
                )
    
    # Return our dictionary
    return ret_dict
