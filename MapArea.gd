extends Node2D

onready var map = get_node("/root/Game/Level/TileMap")
onready var mouse = get_node("/root/Game/Mouse")

var areas = []
var stripes = []

var neighbors = {}

var start_tile
var start_area
var end_tile
var end_area

var astar
var area_path
var point_path

var font
func _ready():
	font = Control.new().get_font("font")
	map.connect("map_changed", self, "on_map_changed")
	mouse.connect("click", self, "on_click")
	build_areas()

func on_map_changed():
	build_areas()

func build_areas():
	stripes = []
	areas = []
	neighbors = {}
	var cur_stripe = null
	for y in range(map.get_used_rect().size.y):
		for x in range(map.get_used_rect().size.x):
			if map.is_walkable(x, y):
				if cur_stripe == null:
					cur_stripe = {tiles=[]}
					cur_stripe.first = Vector2(x, y)
				cur_stripe.last = Vector2(x, y)
				cur_stripe.tiles.append(Vector2(x, y))
			else:
				if cur_stripe:
					stripes.append(cur_stripe)
				cur_stripe = null
		if cur_stripe:
			stripes.append(cur_stripe)
		cur_stripe = null
	
	for stripe in stripes:
		var merged = false
		for area in areas:
			if (area.first.x == stripe.first.x and area.last.x == stripe.last.x) \
			:#or (area.first.y == stripe.first.y and area.last.y == stripe.last.y):
				#if abs(area.last.x - stripe.first.x) <= 1 \
				if abs(area.last.y - stripe.first.y) <= 1:
					area.last = stripe.last
					for tile in stripe.tiles:
						area.tiles.append(tile)
					merged = true
					break
		if not merged:
			areas.append({first = stripe.first, last = stripe.last, tiles = stripe.tiles})
			areas[-1].id = areas.size()-1
	
	for area in areas:
		area.center = (map.map_to_world_centered(area.first) + map.map_to_world_centered(area.last))/2
		neighbors[area.id] = {}
		for pn in areas:
			if area == pn:
				continue
			var exits = test_area_is_neighbor(area, pn)
			if exits.size() > 0:
				neighbors[area.id][pn.id] = {area = pn, exits = exits}
	
	astar = AStar2D.new()
	for area in areas:
		astar.add_point(area.id, area.center)
	for area in areas:
		for nid in neighbors[area.id]:
			astar.connect_points(area.id, nid)
	
	update()

func test_area_is_neighbor(a1, a2):
	var exits = []
	for t1 in a1.tiles:
		for t2 in a2.tiles:
			if test_tile_is_neighbor(t1, t2):
				exits.append({from=t1, to=t2, w_from=map.map_to_world_centered(t1), w_to=map.map_to_world_centered(t2)})
	return exits
func test_tile_is_neighbor(t1, t2):
	if t1.x == t2.x and abs(t1.y - t2.y) == 1:
		return true
	if t1.y == t2.y and abs(t1.x - t2.x) == 1:
		return true
	return false

func on_click(pos, button_mask):
	if button_mask == BUTTON_MASK_LEFT:
		start_tile = map.world_to_map(pos)
		start_area = null
		for area in areas:
			if is_in_area(area, start_tile):
				start_area = area
				break
	elif button_mask == BUTTON_MASK_RIGHT:
		end_tile = map.world_to_map(pos)
		end_area = null
		for area in areas:
			if is_in_area(area, end_tile):
				end_area = area
				break
	if start_tile and end_tile:
		point_path = find_point_path(start_tile, end_tile)
	update()

func find_area_path(t_from, t_to):
	var from_area = get_area_of_tile(t_from)
	if from_area == null: return
	var to_area = get_area_of_tile(t_to)
	if to_area == null: return
	return astar.get_id_path(from_area.id, to_area.id)

func find_point_path(t_from, t_to):
	var area_path = find_area_path(t_from, t_to)
	if area_path == null: return
	var point_path = [map.map_to_world_centered(t_from)]
	for i in range(area_path.size()-1):
		var cur_area = areas[area_path[i]]
		var exits = neighbors[cur_area.id][areas[area_path[i+1]].id].exits
		var closest = null
		var dist
		for e in exits:
			var d = point_path[-1].distance_squared_to(e.w_from)
			if closest == null or d < dist:
				closest = e
				dist = d
		point_path.append(closest.w_from)
		point_path.append(closest.w_to)
	point_path.append(map.map_to_world_centered(t_to))
	return point_path

func closest_exit(point, from_area, to_area):
	if not neighbors[from_area.id].has(to_area.id):
		return
	var exits = neighbors[from_area.id][to_area.id].exits
	var closest = null
	var dist
	for e in exits:
		var d = point.distance_squared_to(e.w_from)
		if closest == null or d < dist:
			closest = e
			dist = d
	return closest

func get_area_of_tile(tile):
	for area in areas:
		if is_in_area(area, tile):
			return area

func is_in_area(area, tile):
	if tile.x < area.first.x:
		return false
	if tile.x > area.last.x:
		return false
	if tile.y < area.first.y:
		return false
	if tile.y > area.last.y:
		return false
	return true


func _draw():
#	for stripe in stripes:
#		draw_tile_area(stripe.first, stripe.last, Color.white, true, 1, 4)
	for area in areas:
		draw_tile_area(area.first, area.last, Color.blue, false)
		var w = area.last.x - area.first.x + 1
		var h = area.last.y - area.first.y + 1
		draw_string(font, map.map_to_world(area.first)+Vector2(0, 12), "%dx%d = %d tiles"%[w, h, w*h])
	
	if point_path:
		var last = point_path[0]
		for p in point_path:
			draw_line(last, p, Color.black)
			draw_circle(p, 4, Color.black)
			last = p
	
	if start_tile:
		draw_single_tile(start_tile, Color.white, true)
	if end_tile:
		draw_single_tile(end_tile, Color.white, true)

func foo():
	if start_area:
		draw_tile_area(start_area.first, start_area.last, Color.blue, false, 3)
		for tile in start_area.tiles:
			draw_single_tile(tile, Color(0, 0, 1, 0.2), true, 1, 12)
		for nid in neighbors[start_area.id]:
			var n = areas[nid]
			draw_tile_area(n.first, n.last, Color.orange, false, 3, 3)
			for exit in neighbors[start_area.id][nid].exits:
				draw_single_tile(exit.from, Color.blue, false, 1, 12)
	if end_area:
		draw_tile_area(end_area.first, end_area.last, Color.green, false, 3)
		for tile in end_area.tiles:
			draw_single_tile(tile, Color(0, 1, 0, 0.2), true, 1, 12)
		for nid in neighbors[end_area.id]:
			var n = areas[nid]
			draw_tile_area(n.first, n.last, Color.orange, false, 3, 3)
			for exit in neighbors[end_area.id][nid].exits:
				draw_single_tile(exit.from, Color.green, false, 1, 12)

func draw_single_tile(tile, color, filled=false, line_w=1, diff=0):
	draw_tile_area(tile, tile, color, filled, line_w, diff)
func draw_tile_area(t_start, t_end, color, filled=false, line_w=1, diff=0):
	var rect = tile_area_to_rect(t_start, t_end, diff)
	draw_rect(rect, color, filled, line_w)
func tile_area_to_rect(t_start, t_end, diff=0):
	var first = map.map_to_world(t_start)
	return Rect2(first+ Vector2(diff, diff), map.map_to_world(t_end)-first + map.cell_size - Vector2(diff*2, diff*2))
func single_tile_rect(tile, diff=0):
	var first = map.map_to_world(tile)
	return Rect2(first + Vector2(diff, diff), map.cell_size - Vector2(diff*2, diff*2))
