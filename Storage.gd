extends Node2D

onready var game = get_node("/root/Game")

export (PackedScene) var Chunk
export (Color) var color = Color.green

var chunks = []

func add_chunk(tiles):
	var chunk = Chunk.instance()
	chunks.append(chunk)
	chunk.map = game.current_level.tilemap
	chunk.tiles = tiles.duplicate()
	chunk.color = color
	add_child(chunk)

func get_storage_tile(t_ant_pos, item):
	var t_closest = null
	var dist = 0
	for chunk in chunks:
		var tile = chunk.get_available_tile_for(item)
		if tile == null:
			continue
		var d = t_ant_pos.distance_squared_to(tile)
		if t_closest == null or d < dist:
			t_closest = tile
			dist = d
	return t_closest

func deposit(item, tile):
	var chunk = get_chunk_for(tile)
	if chunk == null:
		return false
	return chunk.deposit(item, tile)

func get_chunk_for(tile):
	for chunk in chunks:
		if chunk.tiles.has(tile):
			return chunk

func closest_chunk_with_category(t_pos, cat):
	var closest = null
	var dist
	for chunk in chunks:
		var tile = chunk.get_tile_with_category(cat)
		if tile:
			var d = t_pos.distance_squared_to(tile)
			if closest == null or d < dist:
				closest = {tile=tile, chunk=chunk}
				dist = d
	if closest:
		closest["items"] = closest.chunk.storage[closest.tile]
		return closest
