extends Spatial

const DEBUG_BUILDING = preload("res://debug/DebugBuilding.tscn")

const BLOCKS = 20
const BLOCK_BUILDING_WIDTH = 5
const BLOCK_BUILDINGS = BLOCK_BUILDING_WIDTH * 11

const FOOTPRINT_SIZE = 2
const BUILDING_SIZE = .5 

const BUILDING_SPACING_X = 2
const BUILDING_SPACING_Z = 0

const BASE_Y = BUILDING_SIZE
const Z_STEP = 1

func make():
    
    var block_origin
    var building_shift
    var new_building
    
    var x
    var z
    
    block_origin = Vector3.ZERO
    
    for block_num in range(BLOCKS):
        for building_num in range(BLOCK_BUILDINGS):
            building_shift = block_origin
            x = building_num % BLOCK_BUILDING_WIDTH
            z = int(building_num / BLOCK_BUILDING_WIDTH)
            
            building_shift.x += x * FOOTPRINT_SIZE
            building_shift.x += x * BUILDING_SPACING_X
            
            building_shift.z += z * FOOTPRINT_SIZE
            building_shift.z += z * BUILDING_SPACING_Z
            
            print(x, " ", z, " ", building_shift)
            
            new_building = DEBUG_BUILDING.instance()
            new_building.footprint_x = FOOTPRINT_SIZE
            new_building.footprint_z = FOOTPRINT_SIZE
            new_building.building_x = BUILDING_SIZE
            new_building.building_z = BUILDING_SIZE
            new_building.building_y = 2
            
            self.add_child(new_building)
            new_building.translation = building_shift
            new_building.connect("screen_entered", self, "_on_building_screen_entered")
            new_building.connect("screen_exited", self, "_on_building_screen_exited")
            
            if new_building.is_onscreen():
                new_building.set_onscreen_mode()
            else:
                new_building.set_offscreen_mode()
            
        # Alright - move the block origin over!
        block_origin.x += FOOTPRINT_SIZE * BLOCK_BUILDING_WIDTH
        block_origin.x += BUILDING_SPACING_X * BLOCK_BUILDING_WIDTH

func _on_building_screen_entered(building):
    building.set_onscreen_mode()

func _on_building_screen_exited(building):
    # We'll use this to calculate how much to translate the building by
    var trans = Vector3.ZERO

    # Set the building to offscreen mode
    building.set_offscreen_mode()
    
    trans.x += FOOTPRINT_SIZE * BLOCK_BUILDING_WIDTH
    trans.x += BUILDING_SPACING_X * BLOCK_BUILDING_WIDTH
    trans.x *= BLOCKS
    
    # Shift it!
    building.translation += trans
