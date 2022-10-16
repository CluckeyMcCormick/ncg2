extends Spatial

const LIGHT_SCRIPT = preload("res://decorations/CityLight.gd")

const MARGIN = 0.01

const AABB_SCALAR = 2

export(float) var footprint_x setget set_fpx
export(float) var footprint_z setget set_fpz
export(float) var building_x setget set_bldx
export(float) var building_z setget set_bldz
export(float) var building_y setget set_bldy
export(float) var light_range setget set_light_range

# Signal emitted when this building enters the screen - basically an echo of the
# VisibilityNotifier's screen_entered signal.
signal screen_entered(building)

# Ditto, but for when the building exits the screen.
signal screen_exited(building)

func _ready():
    
    var light_arr = [ $"+X+Z", $"+X-Z", $"-X+Z", $"-X-Z" ]
    
    for light_node in light_arr:
        match randi() % 4:
            0:
                light_node.type = LIGHT_SCRIPT.LightCategory.ONE
            1:
                light_node.type = LIGHT_SCRIPT.LightCategory.TWO
            2:
                light_node.type = LIGHT_SCRIPT.LightCategory.THREE
            3:
                light_node.type = LIGHT_SCRIPT.LightCategory.FOUR
    
    _building_update()

func _building_update():
    
    # Move the lights to the base of the building
    $"+X+Z".translation = Vector3(
        ( building_x / 2.0) + MARGIN, 0, ( building_z / 2.0) + MARGIN
    )
    $"+X-Z".translation = Vector3(
        ( building_x / 2.0) + MARGIN, 0, (-building_z / 2.0) - MARGIN
    )
    $"-X+Z".translation = Vector3(
        (-building_x / 2.0) - MARGIN, 0, ( building_z / 2.0) + MARGIN
    )
    $"-X-Z".translation = Vector3(
        (-building_x / 2.0) - MARGIN, 0, (-building_z / 2.0) - MARGIN
    )
    
    # Set the range of the lights
    $"+X+Z".omni_range = light_range
    $"+X-Z".omni_range = light_range
    $"-X+Z".omni_range = light_range
    $"-X-Z".omni_range = light_range
    
    # Set the scale appropriately
    $Box.scale = Vector3(building_x, building_y, building_z)
    # Move the box
    $Box.translation.y = building_y / 2.0
    
    # Set the AABB's size - we don't care about y so that'll just be 100
    $Vis.aabb.size.x = (light_range * 2.0 * AABB_SCALAR) + footprint_x
    $Vis.aabb.size.z = (light_range * 2.0 * AABB_SCALAR) + footprint_x
    $Vis.aabb.size.y = 100
    
    # Set the AABB's position
    $Vis.aabb.position.x = -( $Vis.aabb.size.x / 2.0 )
    $Vis.aabb.position.z = -( $Vis.aabb.size.z / 2.0 )
    $Vis.aabb.position.y = 0

func is_onscreen():
    return $Vis.is_on_screen()

# --------------------------------------------------------
#
# Setters and Getters
#
# --------------------------------------------------------
func set_offscreen_mode():
    $Box.visible = false
    $"+X+Z".visible = false
    $"+X-Z".visible = false
    $"-X+Z".visible = false
    $"-X-Z".visible = false

func set_onscreen_mode():
    $Box.visible = true
    $"+X+Z".visible = true
    $"+X-Z".visible = true
    $"-X+Z".visible = true
    $"-X-Z".visible = true

func set_fpx(new_x):
    # Clamp it
    footprint_x = clamp(new_x, MARGIN * 2, INF)
    
    # Ensure the building x is acceptable
    building_x = clamp(building_x, MARGIN, footprint_x - MARGIN)
    
    # Update the buildings
    _building_update()

func set_fpz(new_z):
    # Clamp it
    footprint_z = clamp(new_z, MARGIN * 2, INF)
    
    # Ensure the building z is acceptable
    building_z = clamp(building_z, MARGIN, footprint_z - MARGIN)
    
    # Update the buildings
    _building_update()

func set_bldx(new_x):
    # Ensure the building x is acceptable
    building_x = clamp(new_x, MARGIN, footprint_x - MARGIN)
    
    # Update the buildings
    _building_update()

func set_bldz(new_z):
    # Ensure the building z is acceptable
    building_z = clamp(new_z, MARGIN, footprint_z - MARGIN)
    
    # Update the buildings
    _building_update()

func set_bldy(new_y):
    # Ensure the building y is acceptable
    building_y = clamp(new_y, MARGIN, INF)
    
    # Update the buildings
    _building_update()

func set_light_range(new_range):
    light_range = clamp(new_range, MARGIN * 2, INF)
    
    # Update the buildings
    _building_update()

# --------------------------------------------------------
#
# Screen Enter/Exit
#
# --------------------------------------------------------

func _on_Vis_screen_entered():
    emit_signal("screen_entered", self)

func _on_Vis_screen_exited():
    emit_signal("screen_exited", self)
