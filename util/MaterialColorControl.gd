extends Node

# Load our different materials
const lighten_material = preload("res://buildings/BuildingMaterialLighten.tres")
const dodge_material = preload("res://buildings/BuildingMaterialDodge.tres")

# This controls what materials new buildings come out as.
var primary_material = lighten_material

# The three kinds of light colors. We start monochromatic because, honestly,
# that JUST LOOKS BETTER. However, we keep this feature around because who
# knows - someone might find use for it.
var light_color_one : Color = Color("#990101")
var light_color_two : Color = Color("#990101")
var light_color_three : Color = Color("#990101")
