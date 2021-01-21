extends Node

onready var ant = get_parent()
onready var path_maker = get_node("/root/Game/PathMaker")
var map

var t_goal = null setget set_goal
var path = null
var w_walking_to = null
var w_last_pos = null
var walk_t = 0.0
var walk_speed = 5
var waiting_path = 0

func _ready():
	yield(get_tree(), "idle_frame")
	map = ant.tilemap

func _process(delta):
	if w_walking_to:
		ant.position = lerp(w_last_pos, w_walking_to, walk_t)
		ant.rotation = lerp_angle(ant.rotation, (w_walking_to-w_last_pos).angle(), 0.3)
		walk_t += delta*walk_speed
		if walk_t > 1.0:
			w_walking_to = null
			walk_t -= 1.0
		
	elif has_path():
		w_walking_to = path[0]+Vector2(rand_range(-5, 5), rand_range(-5, 5)) #map.map_to_world_centered(path[0])
		w_last_pos = ant.position
		path.remove(0)

func set_goal(t_new_goal):
	if is_waiting_path() and t_goal == t_new_goal: return
	t_goal = t_new_goal
	var current_tile = ant.get_tile_position()
	path_maker.request_path(current_tile, t_goal, self)
	waiting_path += 1
func answer_request(_r, t_path):
	waiting_path -= 1
	if t_path:
		t_path.remove(0)
		set_tile_path(t_path)
func is_waiting_path(): return waiting_path > 0
func set_tile_path(tile_path):
	path = []
	for tile in tile_path:
		path.append(map.map_to_world_centered(tile))
	if path.size() > 0:
		path.append(path[-1]) # copy the last position to ensure arrival on target

func has_path():
	return path and not path.empty()

func is_on_tile(tile):
	return ant.get_tile_position() == tile
func on_same_tile(w_pos):
	#print("am on same tile ", ant.get_tile_position(), map.world_to_map(w_pos))
	return is_on_tile(map.world_to_map(w_pos))

func on_neighbor_tile(tile):
	return map.world_to_map(ant.position).distance_to(tile) < 1.1
func close_enough_to_tile(tile):
	return close_enough(map.map_to_world_centered(tile))
func close_enough(w_pos):
	return ant.position.distance_to(w_pos) < 16

func set_path_to_neighbor(tile):
	var my_tile = ant.get_tile_position()
	var ns = map.get_walkable_neighbors(tile)
	var t_path = null
	for n in ns:
		var p = map.find_path(my_tile, n)
		if t_path == null or (p and p.size() < t_path.size()):
			t_path = p
	if t_path:
		t_goal = t_path[-1]
		ant.movement.set_tile_path(t_path)
