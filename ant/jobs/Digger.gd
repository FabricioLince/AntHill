extends "res://ant/jobs/Job.gd"
class_name Digger
const job_name = "Digger"

onready var task_system = get_node("/root/Game/TaskSystem/DigTaskSystem")
onready var path_maker = get_node("/root/Game/PathMaker")

var current_task = null
var dig_time = 0.0

var cur_path
var possible_goals = []
var waiting_path = false

func _ready():
	ant.get_node("Sprite").modulate = Color.brown
	add_state("idle")
	add_state("searching_wall")
	add_state("going_to_wall")
	add_state("digging")
	call_deferred("set_state", states.idle)
	set_physics_process(false)

func _get_transition(delta):
	if current_task and not current_task.valid:
		return states.idle
	match state:
		states.idle:
			current_task = task_system.get_task()
			if current_task:
				possible_goals = movement.map.get_walkable_neighbors(current_task.tile)
				return states.searching_wall
		states.searching_wall:
			if waiting_path:
				pass
			else:
				if possible_goals.size() > 0:
					path_maker.request_path(ant.get_tile_position(), possible_goals[0], self)
					waiting_path = true
					possible_goals.remove(0)
				else:
					if cur_path:
						movement.set_tile_path(cur_path)
						return states.going_to_wall
					else:
						task_system.push_task(current_task)
						current_task = null
						return states.idle
			movement.set_path_to_neighbor(current_task.tile)
			if movement.has_path() and movement.t_goal.distance_to(current_task.tile)<1.415:
				movement.path.append(ant.tilemap.map_to_world_centered(current_task.tile))
				return states.going_to_wall
			else:
				task_system.push_task(current_task)
				current_task = null
				return states.idle
		states.going_to_wall:
			if movement.on_neighbor_tile(current_task.tile):
				dig_time = 0.2
				#ant.position = (ant.position + ant.tilemap.map_to_world_centered(current_task.tile))/2
				return states.digging
			elif not movement.has_path():
				return states.searching_wall
		states.digging:
			ant.rotation += rand_range(-PI/8, PI/8)
			dig_time -= delta
			if dig_time < 0:
				ant.tilemap.set_cellv(current_task.tile, 0)
				ant.tilemap.update_for_tile(current_task.tile)
				current_task.set_done()
				current_task = null
				return states.idle

func answer_request(_r, path):
	waiting_path = false
	if path:
		if cur_path == null or path.size() < cur_path.size():
			cur_path = path
