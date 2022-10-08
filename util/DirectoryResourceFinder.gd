
# Loads the possible resources from the in_path directory; but only those that
# match the given extension.
static func get_path_resources(in_path, extension):
    # What are the paths to our different textures?
    var resources = []
    # What's the current file we're looking at?
    var file_name
    
    # Now we need to dynamically build up our list of blocks we can use. To do
    # so, we're gonna take a look at the blocks directory and see what we can
    # do.
    var dir = Directory.new()
    
    # If the directory didn't open, then we can't really do anything at all.
    # Ergo, we'll have to back out.
    if dir.open(in_path) != OK:
        print("Couldn't open ", in_path, "! Can't do anything!!!")
        return resources
    
    # Start the directory-listing-processing thing.
    dir.list_dir_begin(true)
    
    # Get the first file in the directory listing
    file_name = dir.get_next()
    # While we still have a file...
    while file_name != "":
        # If the current file is a directory...
        if dir.current_is_dir():
            # Skip this file!
            file_name = dir.get_next()
            continue
        
        # If the current file is an import...
        if ".import" in file_name.to_lower():
            # Skip this file!
            file_name = dir.get_next()
            continue
            
        # If the current file has the appropriate extension...
        if extension in file_name.to_lower():
            # Then add it to the choice list!
            resources.append(in_path + file_name)
        
        # Now that we've checked the filename and done any necessary actions,
        # get the next file name.
        file_name = dir.get_next()
    
    # Finish off the directory listing processing... thing.
    dir.list_dir_end()
    
    # Return the final resource listing
    return resources
