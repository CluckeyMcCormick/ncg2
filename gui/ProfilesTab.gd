extends Tabs

# Grab the MaterialColorControl Node - this will allow us to change colors and
# materials on the fly.
onready var mcc = get_node("/root/MaterialColorControl")

var resources = [
    preload("res://profiles/Niteflyte.tres"),
    preload("res://profiles/Sunrise.tres"),
    preload("res://profiles/Velvet.tres"),
    preload("res://profiles/Sailor.tres"),
    preload("res://profiles/TWA.tres"),
]

func _ready():
    for res in resources:
        $VBox/ProfileSelection.add_item(res.profile_name)
    
    $VBox/ProfileSelection.select(0)

func assert_profile():
    _on_ProfileSelection_item_selected(
        $VBox/ProfileSelection.get_selected_items()[0]
    )

func _on_ProfileSelection_item_selected(index):
    mcc.profile_dict = resources[index].to_dict()
    mcc.update_whole_dictionary()
