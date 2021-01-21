extends "res://ant/jobs/Job.gd"
class_name Nurse
const job_name = "Nurse"

onready var bag = get_node("../Bag")
onready var nursary = get_node("/root/Game/Level/Areas/Nursary")
onready var task_system = get_node("/root/Game/TaskSystem/NewEggTaskSystem")

var current_task = null
var tile_to_deposit = null
var timer 

func _ready():
	ant.get_node("Sprite").modulate = Color.pink
	add_state("idle")
	add_state("searching_egg")
	add_state("fetching_egg")
	add_state("searching_nursary")
	add_state("storing_egg")
	call_deferred("set_state", states.idle)
	set_physics_process(false)

func _get_transition(delta):
	if current_task and not current_task.valid:
		current_task = null
		return states.idle
	match state:
		states.idle:
			current_task = task_system.get_task()
			if current_task != null and current_task.valid:
				var egg_tile = ant.tilemap.world_to_map(current_task.item.position)
				movement.set_goal(egg_tile)
				return states.searching_egg
		states.searching_egg:
			if not movement.is_waiting_path():
				if movement.has_path():
					return states.fetching_egg
				elif movement.close_enough(current_task.item.position):
					return states.fetching_egg
				else:
					task_system.push_task(current_task)
					return states.idle
		states.fetching_egg:
			timer -= delta
			if timer < 0:
				return states.searching_egg
			if movement.close_enough(current_task.item.position):
				if bag.hold(current_task.item):
					return states.searching_nursary
		states.searching_nursary:
			if tile_to_deposit == null:
				tile_to_deposit = nursary.get_storage_tile(ant.get_tile_position(), bag.holding)
				if not tile_to_deposit:
					task_system.push_task(current_task)
					bag.drop()
					return states.idle
			else:
				if set_goal_if_can(tile_to_deposit):
					return states.storing_egg
		states.storing_egg:
			if movement.is_on_tile(tile_to_deposit):
				if nursary.deposit(bag.holding, tile_to_deposit):
					bag.drop()
					current_task = null
					return states.idle
				else:
					tile_to_deposit = null
					return states.searching_nursary
			elif not movement.has_path():
				return states.searching_nursary

func _enter_state(new_state, _o):
	if new_state == states.fetching_egg:
		timer = 1.0

func set_goal_if_can(tile):
	if not movement.is_waiting_path():
		movement.set_goal(tile)
	if movement.has_path() and movement.t_goal == tile:
		return true
	if movement.close_enough_to_tile(tile):
		return true
