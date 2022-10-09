extends MenuButton

# (c) 2022 Nicolas McCormick Fredrickson
# This code is licensed under the MIT license (see LICENSE.txt for details)

# The menu items are fixed, with fixed IDs, so we need these constants to refer
# to them.
const BUILDING_A_ID =  0
const BUILDING_B_ID = 10
const BUILDING_C_ID = 20
const LIGHTS_ID = 30
const BEACON_ID = 40
const BOX_ID = 50
const ANTENNA_ID = 60

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
        BOX_ID:
            $RoofBoxDialog.popup_centered_minsize()
        ANTENNA_ID:
            $AntennaDialog.popup_centered_minsize()
