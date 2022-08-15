extends MenuButton

# The menu items are fixed, with fixed IDs, so we need these constants to refer
# to them.
const TEXTURE_ID = 0
const LIGHTS_ID = 10
const BEACON_ID = 20

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
        TEXTURE_ID:
            $TextureDialog.popup_centered_minsize()
        LIGHTS_ID:
            $LightDialog.popup_centered_minsize()
        BEACON_ID:
            $BeaconDialog.popup_centered_minsize()

func _on_TextureDialog_resized():
    _texture_dialog_resize()

func _on_LightDialog_resized():
    _light_dialog_resize()

func _on_BeaconDialog_resized():
    _beacon_dialog_resize()

func _on_Buildings_resized():
    _texture_dialog_resize()

func _on_Lights_resized():
    _light_dialog_resize()

func _on_Beacons_resized():
    _beacon_dialog_resize()

#
# Resize reaction functions
#
func _texture_dialog_resize():
    var target_size
    
    target_size = $"%Buildings".rect_size.x 
    target_size += $"%TextureMargin".get_constant("margin_left")
    target_size += $"%TextureMargin".get_constant("margin_right")
    if $TextureDialog.rect_size.x < target_size:
        $TextureDialog.rect_size.x = target_size

    target_size = $"%Buildings".rect_size.y
    target_size += $"%TextureMargin".get_constant("margin_top")
    target_size += $"%TextureMargin".get_constant("margin_bottom")
    if $TextureDialog.rect_size.y < target_size:
        $TextureDialog.rect_size.y = target_size

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
