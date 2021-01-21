extends "res://ant/jobs/Job.gd"
class_name Collector

const job_name = "Collector"

onready var bag = get_node("../Bag")
onready var storage = get_node("/root/Game/Level/Areas/Storage")
onready var task_system = get_node("/root/Game/TaskSystem/CollectTaskSystem")

var current_task = null
var tile_to_deposit = null
var timer

func _ready():
	ant.get_node("Sprite").modulate = Color.navyblue
	add_state("idle")
	add_state("searching_item")
	add_state("fetching_item")
	add_state("searching_storage")
	add_state("storing_item")
	call_deferred("set_state", states.idle)
	set_physics_process(false)

func _get_transition(delta):
	if current_task and not current_task.valid:
		current_task = null
		return states.idle
	match state:
		states.idle:
			timer -= delta
			if timer < 0:
				current_task = task_system.get_task()
				if current_task != null:
					return states.searching_item
		states.searching_item:
			timer -= delta
			if timer < 0:
				task_system.push_task(current_task)
				return states.idle
			var tile = ant.tilemap.world_to_map(current_task.item.position)
			if set_goal_if_can(tile):
				return states.fetching_item
			if movement.close_enough(current_task.item.position):
				return states.fetching_item
		states.fetching_item:
			if movement.close_enough(current_task.item.position):
				if bag.hold(current_task.item):
					return states.searching_storage
				else:
					current_task = null
					return states.idle
			elif not movement.has_path() and not movement.is_waiting_path():
				return states.searching_item
		states.searching_storage:
			if tile_to_deposit == null:
				tile_to_deposit = storage.get_storage_tile(ant.get_tile_position(), bag.holding)
				if not tile_to_deposit:
					bag.drop()
					return states.idle
			else:
				if set_goal_if_can(tile_to_deposit):
					return states.storing_item
		states.storing_item:
			if not bag.holding:
				return states.idle
			if movement.is_on_tile(tile_to_deposit):
				if storage.deposit(bag.holding, tile_to_deposit):
					bag.drop()
					current_task = null
					return states.idle
				else:
					tile_to_deposit = null
					return states.searching_storage

func _enter_state(new_state, _o):
	if new_state == states.searching_item:
		timer = 1.0
	if new_state == states.idle:
		timer = 1.0

func set_goal_if_can(tile):
	if not movement.is_waiting_path():
		movement.set_goal(tile)
	if movement.has_path() and movement.t_goal == tile:
		return true

