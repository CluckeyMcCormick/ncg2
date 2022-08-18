extends MenuButton

# The menu items are fixed, with fixed IDs, so we need these constants to refer
# to them.
const BUILDING_A_ID =  0
const BUILDING_B_ID = 10
const BUILDING_C_ID = 20
const LIGHTS_ID = 30
const BEACON_ID = 40

# Called when the node enters the scene tree for the first time.
func _ready():
    # First, get the pop-up menu
    var popup = self.get_popup()
    # Connect to the id_pressed signal so we know when the user did something.
    popup.connect("id_pressed", self, "_on_popup_id_pressed")

#
# Signal Functions
#
func _on_popup_id_pressed(id):
    match id:
        BUILDING_A_ID:
            $BuildingADialog.popup_centered_minsize()
        BUILDING_B_ID:
            $BuildingBDialog.popup_centered_minsize()
        BUILDING_C_ID:
            $BuildingCDialog.popup_centered_minsize()
        LIGHTS_ID:
            $LightDialog.popup_centered_minsize()
        BEACON_ID:
            $BeaconDialog.popup_centered_minsize()

func _on_BuildingADialog_resized():
    _buildingA_dialog_resize()

func _on_BuildingBDialog_resized():
    _buildingB_dialog_resize()

func _on_BuildingCDialog_resized():
    _buildingC_dialog_resize()

func _on_LightDialog_resized():
    _light_dialog_resize()

func _on_BeaconDialog_resized():
    _beacon_dialog_resize()

func _on_Lights_resized():
    _light_dialog_resize()

func _on_Beacons_resized():
    _beacon_dialog_resize()

#
# Resize reaction functions
#
func _buildingA_dialog_resize():
    var target_size
    
    target_size = $"%BuildingAControl".rect_size.x 
    target_size += $"%BuildingAMargin".get_constant("margin_left")
    target_size += $"%BuildingAMargin".get_constant("margin_right")
    if $BuildingADialog.rect_size.x < target_size:
        $BuildingADialog.rect_size.x = target_size

    target_size = $"%BuildingAControl".rect_size.y
    target_size += $"%BuildingAMargin".get_constant("margin_top")
    target_size += $"%BuildingAMargin".get_constant("margin_bottom")
    if $BuildingADialog.rect_size.y < target_size:
        $BuildingADialog.rect_size.y = target_size

func _buildingB_dialog_resize():
    var target_size
    
    target_size = $"%BuildingBControl".rect_size.x 
    target_size += $"%BuildingBMargin".get_constant("margin_left")
    target_size += $"%BuildingBMargin".get_constant("margin_right")
    if $BuildingBDialog.rect_size.x < target_size:
        $BuildingBDialog.rect_size.x = target_size

    target_size = $"%BuildingBControl".rect_size.y
    target_size += $"%BuildingBMargin".get_constant("margin_top")
    target_size += $"%BuildingBMargin".get_constant("margin_bottom")
    if $BuildingBDialog.rect_size.y < target_size:
        $BuildingBDialog.rect_size.y = target_size

func _buildingC_dialog_resize():
    var target_size
    
    target_size = $"%BuildingCControl".rect_size.x 
    target_size += $"%BuildingCMargin".get_constant("margin_left")
    target_size += $"%BuildingCMargin".get_constant("margin_right")
    if $BuildingCDialog.rect_size.x < target_size:
        $BuildingCDialog.rect_size.x = target_size

    target_size = $"%BuildingCControl".rect_size.y
    target_size += $"%BuildingCMargin".get_constant("margin_top")
    target_size += $"%BuildingCMargin".get_constant("margin_bottom")
    if $BuildingCDialog.rect_size.y < target_size:
        $BuildingCDialog.rect_size.y = target_size


func _light_dialog_resize():
    var target_size
    
    target_size = $"%Lights".rect_size.x 
    target_size += $"%LightMargin".get_constant("margin_left")
    target_size += $"%LightMargin".get_constant("margin_right")
    if $LightDialog.rect_size.x < target_size:
        $LightDialog.rect_size.x = target_size

    target_size = $"%Lights".rect_size.y
    target_size += $"%LightMargin".get_constant("margin_top")
    target_size += $"%LightMargin".get_constant("margin_bottom")
    if $LightDialog.rect_size.y < target_size:
        $LightDialog.rect_size.y = target_size

func _beacon_dialog_resize():
    var target_size
    
    target_size = $"%Beacons".rect_size.x 
    target_size += $"%BeaconMargin".get_constant("margin_left")
    target_size += $"%BeaconMargin".get_constant("margin_right")
    if $BeaconDialog.rect_size.x < target_size:
        $BeaconDialog.rect_size.x = target_size

    target_size = $"%Beacons".rect_size.y
    target_size += $"%BeaconMargin".get_constant("margin_top")
    target_size += $"%BeaconMargin".get_constant("margin_bottom")
    if $BeaconDialog.rect_size.y < target_size:
        $BeaconDialog.rect_size.y = target_size
