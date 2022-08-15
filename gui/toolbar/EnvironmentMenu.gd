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

func _on_SkyDialog_resized():
    _sky_dialog_resize()

func _on_Sky_resized():
    _sky_dialog_resize()


func _on_StarDialog_resized():
    _star_dialog_resize()

func _on_Starfield_resized():
    _star_dialog_resize()


func _on_MoonDialog_resized():
    _moon_dialog_resize()

func _on_Moon_resized():
    _moon_dialog_resize()


func _on_SparklesDialog_resized():
    _sparkles_dialog_resize()

func _on_Sparkles_resized():
    _sparkles_dialog_resize()


#
# Resize reaction functions
#
func _sky_dialog_resize():
    var target_size
    
    target_size = $"%Sky".rect_size.x 
    target_size += $"%SkyMargin".get_constant("margin_left")
    target_size += $"%SkyMargin".get_constant("margin_right")
    if $SkyDialog.rect_size.x < target_size:
        $SkyDialog.rect_size.x = target_size

    target_size = $"%Sky".rect_size.y
    target_size += $"%SkyMargin".get_constant("margin_top")
    target_size += $"%SkyMargin".get_constant("margin_bottom")
    if $SkyDialog.rect_size.y < target_size:
        $SkyDialog.rect_size.y = target_size

func _star_dialog_resize():
    var target_size
    
    target_size = $"%Starfield".rect_size.x 
    target_size += $"%StarMargin".get_constant("margin_left")
    target_size += $"%StarMargin".get_constant("margin_right")
    if $StarDialog.rect_size.x < target_size:
        $StarDialog.rect_size.x = target_size

    target_size = $"%Starfield".rect_size.y
    target_size += $"%StarMargin".get_constant("margin_top")
    target_size += $"%StarMargin".get_constant("margin_bottom")
    if $StarDialog.rect_size.y < target_size:
        $StarDialog.rect_size.y = target_size

func _moon_dialog_resize():
    var target_size
    
    target_size = $"%Moon".rect_size.x 
    target_size += $"%MoonMargin".get_constant("margin_left")
    target_size += $"%MoonMargin".get_constant("margin_right")
    if $MoonDialog.rect_size.x < target_size:
        $MoonDialog.rect_size.x = target_size

    target_size = $"%Moon".rect_size.y
    target_size += $"%MoonMargin".get_constant("margin_top")
    target_size += $"%MoonMargin".get_constant("margin_bottom")
    if $MoonDialog.rect_size.y < target_size:
        $MoonDialog.rect_size.y = target_size

func _sparkles_dialog_resize():
    var target_size
    
    target_size = $"%Sparkles".rect_size.x 
    target_size += $"%SparklesMargin".get_constant("margin_left")
    target_size += $"%SparklesMargin".get_constant("margin_right")
    if $SparklesDialog.rect_size.x < target_size:
        $SparklesDialog.rect_size.x = target_size
    
    target_size = $"%Sparkles".rect_size.y
    target_size += $"%SparklesMargin".get_constant("margin_top")
    target_size += $"%SparklesMargin".get_constant("margin_bottom")
    if $SparklesDialog.rect_size.y < target_size:
        $SparklesDialog.rect_size.y = target_size
