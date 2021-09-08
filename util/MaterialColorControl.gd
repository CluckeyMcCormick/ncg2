extends Node

# Load our different materials
const dot_material = preload("res://buildings/DotWindowMaterial.tres")
# These need to be var because otherwise we can't modify the "Albedo Color"
# member variable.
var type_a_material = preload("res://effects/StarTypeA.tres")
var type_b_material = preload("res://effects/StarTypeB.tres")
var type_c_material = preload("res://effects/StarTypeC.tres")

# Load our different Building textures
const horiz64_25 = preload("res://buildings/dots64_horizontal64_25hs.png")
const horiz64_50 = preload("res://buildings/dots64_horizontal64_50hs.png")
const horiz64_75 = preload("res://buildings/dots64_horizontal64_75hs.png")
const horiz64_100 = preload("res://buildings/dots64_horizontal64_100h.png")

const verti64_25 = preload("res://buildings/dots64_vertical64_25hs.png")
const verti64_50 = preload("res://buildings/dots64_vertical64_50hs.png")
const verti64_75 = preload("res://buildings/dots64_vertical64_75hs.png")
const verti64_100 = preload("res://buildings/dots64_vertical64_100h.png")

# Load our different star textures
const s64_dot = preload("res://effects/64Dot.png")
const s64_star = preload("res://effects/64Star.png")
const s64_sparkle_a = preload("res://effects/64Sparkles50a.png")
const s64_sparkle_b = preload("res://effects/64Sparkles50b.png")
const s64_sparkle_c = preload("res://effects/64Sparkles50c.png")

# This controls what materials new buildings come out as.
var primary_material = dot_material
