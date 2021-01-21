extends TileMap

signal map_changed()

var astar : AStar2D

func _ready():
	astar = AStar2D.new()
	var width = get_used_rect().size.x
	var height = get_used_rect().size.y
	for x in range(width):
		for y in range(height):
			if is_walkable(x, y):
				astar.add_point(astar.get_available_point_id(), Vector2(x, y))
	
	for id in astar.get_points():
		#print(id, ": ", astar.get_point_position(id))
		var pos = astar.get_point_position(id)
		for n in get_walkable_neighbors(pos):
			var neighbor_id = astar.get_closest_point(n)
			astar.connect_points(id, neighbor_id)

func update_for_tile(tile):
	emit_signal("map_changed")
	var id = astar.get_closest_point(tile)
	if astar.get_point_position(id) != tile:
		#print("new tile ", tile)
		id = astar.get_available_point_id()
		astar.add_point(id, tile)
	for n in get_walkable_neighbors(tile):
		var neighbor_id = astar.get_closest_point(n)
		astar.connect_points(id, neighbor_id)

func get_walkable_neighbors(tile):
	var n = []
	for dx in [-1, +1]:
		if is_walkable(tile.x+dx, tile.y):
			n.append(Vector2(tile.x+dx, tile.y))
			for dy in [-1, +1]:
				if is_walkable(tile.x+dx, tile.y+dy) and \
				is_walkable(tile.x, tile.y+dy):
					n.append(Vector2(tile.x+dx, tile.y+dy))
					
	for dy in [-1, +1]:
		if is_walkable(tile.x, tile.y+dy):
			n.append(Vector2(tile.x, tile.y+dy))
	return n

func find_path(t_from:Vector2, t_to:Vector2):
	if not is_walkablev(t_from) or not is_walkablev(t_to):
		return null
	return find_path_to_close(t_from, t_to)

func find_path_to_close(t_from:Vector2, t_to:Vector2):
	var from_id = astar.get_closest_point(t_from)
	if from_id == -1:
		return null
	var to_id = astar.get_closest_point(t_to)
	if to_id == -1:
		return null
	return astar.get_point_path(from_id, to_id)

func is_walkablev(tile):
	return is_walkable(tile.x, tile.y)
func is_walkable(x, y):
	return get_cell(x, y) == 0

func map_to_world_centered(tile_pos):
	return map_to_world(tile_pos)+cell_size/2
