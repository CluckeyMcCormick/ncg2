extends Node

# Load our different materials
const dot_material = preload("res://buildings/DotWindowMaterial.tres")

# Load our different textures
const horiz64_25 = preload("res://buildings/dots64_horizontal64_25hs.png")
const horiz64_50 = preload("res://buildings/dots64_horizontal64_50hs.png")
const horiz64_75 = preload("res://buildings/dots64_horizontal64_75hs.png")
const horiz64_100 = preload("res://buildings/dots64_horizontal64_100h.png")

const verti64_25 = preload("res://buildings/dots64_vertical64_25hs.png")
const verti64_50 = preload("res://buildings/dots64_vertical64_50hs.png")
const verti64_75 = preload("res://buildings/dots64_vertical64_75hs.png")
const verti64_100 = preload("res://buildings/dots64_vertical64_100h.png")

# This controls what materials new buildings come out as.
var primary_material = dot_material
