extends WindowDialog
class_name SlightlyBetterDialog

# TODO: Replace Pop-up Window/Dialogs with something that doesn't freeze the GUI

# We don't necessarily want to shrink ALL the way down to a minimum size. It may
# be useful to leave some margins on any one side - these variables allow for
# that. Negative values are effectively treated as 0.
export(int) var horizontal_margin = 0
export(int) var vertical_margin = 0

func _ready():
    # Connect our signals. Unless this is done manually, they don't seem to work
    # when instanced in scenes
    self.connect("about_to_show", self, "_on_about_to_show" )
    self.connect("resized", self, "_on_resized")

func _on_about_to_show():
    _resize(true)

func _on_resized():
    _resize()

func _resize(shrink=false):
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
    
    # Apparently there's an issue with Control nodes - sometimes, when you
    # change the rect_size of the node, it won't actually update. In that case,
    # you need to wait for an idle frame. I've had trouble with this
    # yield-to-tree syntax before, but it seems to work here.
    # Thanks to girng @ GitHub for this solution:
    # https://github.com/godotengine/godot/issues/32349
    yield(get_tree(), "idle_frame")
    
    #
    # Step 2: X Size check
    #
    target_size = max_size.x + clamp(horizontal_margin, 0, INF)
    
    if (not shrink) and self.rect_size.x < target_size:
        self.rect_size.x = target_size
        
    if shrink and target_size < self.rect_size.x:
        self.rect_size.x = target_size
    
    #
    # Step 3: Y Size check
    #
    target_size = max_size.y + clamp(vertical_margin, 0, INF)
    
    if (not shrink) and self.rect_size.y < target_size:
        self.rect_size.y = target_size
        
    if shrink and target_size < self.rect_size.y:
        self.rect_size.y = target_size
