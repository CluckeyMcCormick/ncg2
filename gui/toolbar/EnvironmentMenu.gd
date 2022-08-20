extends MenuButton

# The menu items are fixed, with fixed IDs, so we need these constants to refer
# to them.
const SKY_ID = 0
const STAR_ID = 10
const MOON_ID = 20
const SPARKLE_ID = 30

# Echo signal of Starfield's regenerate function
signal regenerate()

# Called when the node enters the scene tree for the first time.
func _ready():
    # First, get the pop-up menu
    var popup = self.get_popup()
    # Connect to the id_pressed signal so we know when the user did something.
    popup.connect("id_pressed", self, "_on_popup_id_pressed")

#
# Signal Functions
#
func _on_Starfield_regenerate():
    emit_signal("regenerate")

func _on_popup_id_pressed(id):
    match id:
        SKY_ID:
            $SkyDialog.popup_centered_minsize()
        STAR_ID:
            $StarDialog.popup_centered_minsize()
        MOON_ID:
            $MoonDialog.popup_centered_minsize()
        SPARKLE_ID:
            $SparklesDialog.popup_centered_minsize()
