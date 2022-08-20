
# Load the GlobalRef script
const GlobalRef = preload("res://util/GlobalRef.gd")

# How long, in pixels, is each side of the core window textures?
const WINDOW_PIXEL_SIZE = 64
# How many windows do we have on one side of our texture? This is just a
# convenience wrapper for WINDOW_CELL_LEN in GlobalRef
const WINDOW_SIDE_COUNT = GlobalRef.WINDOW_CELL_LEN
# Given the WINDOW_PIXEL_SIZE, and WINDOW_SIDE_COUNT, how many pixels constitute
# one side of a building texture?
const BUILDING_SIZE = WINDOW_PIXEL_SIZE * WINDOW_SIDE_COUNT;

# Formats in Godot are a bit tricky - to blit/blend between images, they all
# need to be the same format. With that in mind, we're going to force them all
# to be one format because... well honestly I'm not that imaginitive, I'm very
# lazy  and I can't see the inevitable way this bites me.
const BUILDING_FORMAT = Image.FORMAT_RGBA8

# We'll be building a texture via a pixel-copy operation known as blitting (or
# it might be 'blending', who knows, I'll keep changing it). Anyway, since the
# size of the window is fixed, we can create the RECT2 object ahead of time and
# save ourselves some syntax.
const BLIT_RECT = Rect2(
    Vector2.ZERO, Vector2(WINDOW_PIXEL_SIZE, WINDOW_PIXEL_SIZE)
)

# We support multiple shapes for the windows, and support multiple colors for
# each shape. We'll randomly roll to determine shape and color. This enumerator
# covers our four colors: RED, GREEN, BLUE, and OFF. AKA TRANSPARENT.
enum WindowCode {
    OFF = 0
    RED = 1
    GREEN = 2
    BLUE = 3
}
# When we try to roll a new state, we roll between 0 and some higher value
# minus one: what is that higher value?
const COLOR_ROLL_SIZE = 100
# What's the chance that a particular window will be "off"? (This will trigger
# if we roll <= this number)
const OFF_CHANCE = 63
# What's the chance that a particular window will be RED? (This will trigger
# if we roll <= this number and we roll > OFF_CHANCE)
const RED_CHANCE = 75
# What's the chance that a particular window will be GREEN? (This will trigger
# if we roll <= this number and we roll > RED_CHANCE)
const GREEN_CHANCE = 87
# If we're not OFF or RED OR GREEN, then we will be BLUE. The chance of being
# BLUE can thus be calculated as COLOR_ROLL_SIZE - GREEN_CHANCE.

# We support multiple window algorithms - after all, the sequence in which we
# place the windows results in a unique look for each texture.
enum WindowAlgorithm {
    RANDOM = 0
    HORIZONTAL = 1
    VERTICAL = 2
    DIAGONAL = 3
    ANTI_DIAGONAL = 4
}

# Windows need to come in three colors: red, green, or blue. We need to generate
# these three color windows from a template, which we refer to as a root window.
# This WindowSet class exists to help us easily create RGB window images from
# a root window.
class WindowSet:
    
    # The three color images
    var red
    var green
    var blue
    
    # Creates a window set from a root image. This includes three pixel-by-pixel
    # copies, so you had best be prepare for this to take a second.
    func _init(root_image : Image):
        var color
        
        # Create the window image objects
        red = Image.new()
        green = Image.new()
        blue = Image.new()
        
        # Initialize the window images
        red.create(WINDOW_PIXEL_SIZE, WINDOW_PIXEL_SIZE, false, BUILDING_FORMAT)
        green.create(WINDOW_PIXEL_SIZE, WINDOW_PIXEL_SIZE, false, BUILDING_FORMAT)
        blue.create(WINDOW_PIXEL_SIZE, WINDOW_PIXEL_SIZE, false, BUILDING_FORMAT)
        
        # Lock down the images so we can modify them.
        root_image.lock()
        red.lock()
        green.lock()
        blue.lock()
        
        # For each pixel...
        for x in range(WINDOW_PIXEL_SIZE):
            for y in range(WINDOW_PIXEL_SIZE):
                # Copy the alpha from the pixel while forming the red, green,
                # and blue voices.
                color = root_image.get_pixel(x, y)
                red.set_pixel( x, y, Color(1, 0, 0, color.a) )
                green.set_pixel( x, y, Color(0, 1, 0, color.a) )
                blue.set_pixel( x, y, Color(0, 0, 1, color.a) )
        
        # Unlock the images
        root_image.unlock()
        red.lock()
        green.lock()
        blue.lock()

class WindowGenerator:
    # The image that's being directly modified by the generator. Generally, you
    # shouldn't need to access this.
    var _texture_image
    # The texture created from the above image. This is what you'll want to
    # actually for materials.
    var texture
    
    # When we roll colors, we also roll a "chain length". This many windows will
    # be placed in order before we roll a new color.
    var max_color_chain = 8
    # This is the same thing, but for window shapes instead of colors.
    var max_shape_chain = 1

    func _init():
        _texture_image = Image.new()
        texture = ImageTexture.new()
        
    func paint_random(windows_arr : Array):
        paint_generic(windows_arr, WindowAlgorithm.RANDOM)
    
    func paint_horizontal(windows_arr : Array):
        paint_generic(windows_arr, WindowAlgorithm.HORIZONTAL)

    func paint_vertical(windows_arr : Array):
        paint_generic(windows_arr, WindowAlgorithm.VERTICAL)
    
    func paint_diagonal(windows_arr : Array):
        paint_diagonal_generic(windows_arr, WindowAlgorithm.DIAGONAL)

    func paint_anti_diagonal(windows_arr : Array):
        paint_diagonal_generic(windows_arr, WindowAlgorithm.ANTI_DIAGONAL)
    
    func paint_blank():
        # Create a blank texture image
        _texture_image.create(
            BUILDING_SIZE, BUILDING_SIZE, false, BUILDING_FORMAT
        )
        # Update our texture.
        texture.create_from_image(_texture_image)
    
    func paint_generic(windows_arr : Array, algorithm):
        
        var window_sets = []
        var curr_window
        var curr_color
        var curr_image
        
        var color_chain = 0
        var shape_chain = 0
        
        var x
        var y
        
        # If we didn't get any windows, back out
        if windows_arr.empty():
            return
        
        # For each window, create a window set
        for window in windows_arr:
            window.convert(BUILDING_FORMAT)
            window_sets.append( WindowSet.new(window) )
        
        # Create a blank texture image
        _texture_image.create(
            BUILDING_SIZE, BUILDING_SIZE, false, BUILDING_FORMAT
        )
        
        # For each window...
        for i in range(WINDOW_SIDE_COUNT * WINDOW_SIDE_COUNT):
            match algorithm:
                WindowAlgorithm.RANDOM:
                    x = i % WINDOW_SIDE_COUNT
                    y = i / WINDOW_SIDE_COUNT
                    # Force a chain reroll since this is random
                    shape_chain = 0
                    color_chain = 0
                WindowAlgorithm.HORIZONTAL:
                    x = i % WINDOW_SIDE_COUNT
                    y = i / WINDOW_SIDE_COUNT
                WindowAlgorithm.VERTICAL:
                    x = i / WINDOW_SIDE_COUNT
                    y = i % WINDOW_SIDE_COUNT
                _:
                    return
            
            # If this shape chain is exhausted...
            if shape_chain <= 0:
                # Roll a random window set
                curr_window = window_sets[ randi() % len(window_sets) ]
                # Roll a new length for this shape chain, IF our shape chains
                # last longer than 1
                if max_shape_chain > 1:
                    shape_chain = randi() % (max_shape_chain - 1) + 1
                # Otherwise, well... It's only going to last one anyway.
                else:
                    shape_chain = 1
            
            # If this color chain is exhausted
            if color_chain <= 0:
                # Roll a random color
                curr_color = pick_random_color()
                # Roll a new length for this color chain, IF our color chains
                # last longer than 1
                if max_color_chain > 1:
                    color_chain = randi() % (max_color_chain - 1) + 1
                # Otherwise, well... It's only going to last one anyway.
                else:
                    color_chain = 1
            
            # Now roll a random color image from that random set.
            match curr_color:
                WindowCode.OFF:
                    curr_image = null
                WindowCode.RED:
                    curr_image = curr_window.red
                WindowCode.GREEN:
                    curr_image = curr_window.green
                WindowCode.BLUE:
                    curr_image = curr_window.blue
                _:
                    curr_image = null
            
            # Blend in that that image we selected into the overall building
            # image - if we have an image!
            if curr_image != null:
                _texture_image.blit_rect(
                    curr_image,
                    BLIT_RECT,
                    Vector2( x * WINDOW_PIXEL_SIZE, y * WINDOW_PIXEL_SIZE)
                )
            
            # Knock one off of our shape and color chains
            shape_chain -= 1
            color_chain -= 1
        
        # Update our texture.
        texture.create_from_image(_texture_image)
        # Creating the texture using that create method reset the texture's
        # option flags. We'll need to set them by hand now - turn on repeating
        # (since the city effect relies on that) and ansiotropic filtering (so
        # that we can see the window effect from angles).
        texture.flags = Texture.FLAG_REPEAT | Texture.FLAG_ANISOTROPIC_FILTER
  
    func paint_diagonal_generic(windows_arr : Array, algorithm):
        
        var window_sets = []
        var curr_window
        var curr_color
        var curr_image
        
        var color_chain = 0
        var shape_chain = 0
        
        var x
        var y
        
        # If we didn't get any windows, back out
        if windows_arr.empty():
            return
        
        # For each window, create a window set
        for window in windows_arr:
            window.convert(BUILDING_FORMAT)
            window_sets.append( WindowSet.new(window) )
        
        # Create a blank texture image
        _texture_image.create(
            BUILDING_SIZE, BUILDING_SIZE, false, BUILDING_FORMAT
        )
        
        # As it turns out, incrementing diagonally through a two dimensional
        # array is difficult. Especially if you're doing it at 11:30 at night.
        # Fortunately, I had a Youtube Video to help me:
        #
        # "Print Matrix Diagonally" by "Vivekanand - Algorithm Every Day"
        #
        # Turns out there's a whole hellish logic behind iterating over a matrix
        # diagonally. I got it to work but I've committed somewhat of a
        # programming sin in that really don't understand the logic. It makes
        # a vague sense to me, and that's all I'll say
        for i in range( WINDOW_SIDE_COUNT + WINDOW_SIDE_COUNT - 1):
            match algorithm:
                WindowAlgorithm.DIAGONAL:
                    if i < WINDOW_SIDE_COUNT:
                        x = i
                        y = 0
                    else:
                        x = WINDOW_SIDE_COUNT - 1
                        y = i - WINDOW_SIDE_COUNT + 1
                WindowAlgorithm.ANTI_DIAGONAL:
                    if i < WINDOW_SIDE_COUNT:
                        x = i
                        y = WINDOW_SIDE_COUNT - 1
                    else:
                        x = WINDOW_SIDE_COUNT - 1
                        y = i - WINDOW_SIDE_COUNT + 1
                _:
                    return
            
            while x >= 0:
                # If this shape chain is exhausted...
                if shape_chain <= 0:
                    # Roll a random window set
                    curr_window = window_sets[ randi() % len(window_sets) ]
                    # Roll a new length for this shape chain, IF our shape chains
                    # last longer than 1
                    if max_shape_chain > 1:
                        shape_chain = randi() % (max_shape_chain - 1) + 1
                    # Otherwise, well... It's only going to last one anyway.
                    else:
                        shape_chain = 1
                
                # If this color chain is exhausted
                if color_chain <= 0:
                    # Roll a random color
                    curr_color = pick_random_color()
                    # Roll a new length for this color chain, IF our color chains
                    # last longer than 1
                    if max_color_chain > 1:
                        color_chain = randi() % (max_color_chain - 1) + 1
                    # Otherwise, well... It's only going to last one anyway.
                    else:
                        color_chain = 1
                
                # Now roll a random color image from that random set.
                match curr_color:
                    WindowCode.OFF:
                        curr_image = null
                    WindowCode.RED:
                        curr_image = curr_window.red
                    WindowCode.GREEN:
                        curr_image = curr_window.green
                    WindowCode.BLUE:
                        curr_image = curr_window.blue
                    _:
                        curr_image = null
                
                # Blend in that that image we selected into the overall building
                # image - if we have an image!
                if curr_image != null:
                    _texture_image.blend_rect(
                        curr_image,
                        BLIT_RECT,
                        Vector2( x * WINDOW_PIXEL_SIZE, y * WINDOW_PIXEL_SIZE)
                    )
                
                # Knock one off of our shape and color chains
                shape_chain -= 1
                color_chain -= 1
                
                # Increment ourselves - DIAGONALLY!
                match algorithm:
                    WindowAlgorithm.DIAGONAL:
                        x -= 1
                        y += 1
                    WindowAlgorithm.ANTI_DIAGONAL:
                        x -= 1
                        y -= 1
                    _:
                        return
        
        # Update our texture.
        texture.create_from_image(_texture_image)
        # Creating the texture using that create method reset the texture's
        # option flags. We'll need to set them by hand now - turn on repeating
        # (since the city effect relies on that) and ansiotropic filtering (so
        # that we can see the window effect from angles).
        texture.flags = Texture.FLAG_REPEAT | Texture.FLAG_ANISOTROPIC_FILTER
    
    func pick_random_color():
        var roll = randi() % COLOR_ROLL_SIZE
        
        if roll <= OFF_CHANCE:
            return WindowCode.OFF
        elif roll <= RED_CHANCE:
            return WindowCode.RED
        elif roll <= GREEN_CHANCE:
            return WindowCode.GREEN
        else:
            return WindowCode.BLUE
