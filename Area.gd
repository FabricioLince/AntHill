extends Node2D

signal tile_added(tile)
signal tile_removed(tile)

onready var tilemap = get_node("../../TileMap")

var tiles = []
var color = Color.white

func add_tile(tile):
	if tiles.has(tile):
		return
	tiles.append(tile)
	update()
	emit_signal("tile_added", tile)
func remove_tile(tile):
	if tiles.has(tile):
		tiles.erase(tile)
		update()
		emit_signal("tile_removed", tile)

func _draw():
	for tile in tiles:
		var position = tilemap.map_to_world(tile)
		var size = tilemap.cell_size
		draw_rect(Rect2(position, size), color, false)
