extends Node2D

onready var tilemap = $TileMap
var storage

var font = null

func _ready():
	font = Control.new().get_font("font")
	storage = get_node("Areas/Storage")

func show_tile_pos(w_pos):
	draw_string(font, w_pos, str(tilemap.world_to_map(w_pos)))
