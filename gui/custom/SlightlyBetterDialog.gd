extends WindowDialog
class_name SlightlyBetterDialog

export(int) var child_margin_right = 0
export(int) var child_margin_top = 0
export(int) var child_margin_left = 0
export(int) var child_margin_bottom = 0

func _ready():
    # Connect our signals. Unless this is done manually, they don't seem to work
    # when instanced in scenes
    self.connect("about_to_show", self, "_on_about_to_show" )
    self.connect("resized", self, "_on_resized")

func _on_about_to_show():
    _resize()

func _on_resized():
    _resize()

func _resize():
    var target_size
    var max_size = Vector2(-INF, -INF)
    
    #
    # Step 1: Get the maximum child size
    #
    # Since the WindowDialog doesn't scale with it's children, we need to
    # manually go over each child and find out what are maximum size is. Ideally
    # we only have child, but we can't know that for sure. Also, there's a
    # chance we might(?) be able to do this by connecting to the child's resize
    # method but honestly I'm just going to do this for right now.
    for child in self.get_children():
        if not child is Control:
            continue
        
        if max_size.x < child.rect_size.x:
            max_size.x = child.rect_size.x
            
        if max_size.y < child.rect_size.y:
            max_size.y = child.rect_size.y

    #
    # Step 2: X Size check
    #
    target_size = max_size.x
    target_size += clamp(child_margin_right, 0, INF)
    target_size += clamp(child_margin_left, 0, INF)

    if self.rect_size.x < target_size:
        self.rect_size.x = target_size

    #
    # Step 3: Y Size check
    #
    target_size = max_size.y
    target_size += clamp(child_margin_top, 0, INF)
    target_size += clamp(child_margin_bottom, 0, INF)
    
    if self.rect_size.y < target_size:
        self.rect_size.y = target_size
