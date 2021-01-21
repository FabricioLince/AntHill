extends StateMachine

onready var ant = get_parent()
onready var movement = get_node("../Movement")

onready var storage = get_node("/root/Game/Level/Areas/Storage")
var food_to_eat = null
var eating_counter = 0.0

func _ready():
	add_state("wandering")
	add_state("working")
	add_state("getting_food")
	call_deferred("set_state", states.wandering)
	set_physics_process(false)
	yield(get_tree(), "idle_frame")
	set_physics_process(true)

func _state_logic(delta):
	timer_to_search_food -= delta
	match state:
		states.wandering:
			if ant.get_job():
				ant.job.work(delta)
			if not movement.has_path() and not movement.is_waiting_path():
				wander()
		states.working:
			ant.job.work(delta)
		states.getting_food:
			if is_instance_valid(food_to_eat):
				if ant.movement.on_same_tile(food_to_eat.position):
					food_to_eat.held = ant
					#ant.rotation = ant.position.angle_to(food_to_eat.position)+sin(OS.get_ticks_msec()*1000)*PI/2
					ant.rotation += delta * 5
					var nut = food_to_eat.nutrition * delta
					ant.status.food += nut
					food_to_eat.nutrition -= nut
					if food_to_eat.nutrition < 0.01:
						food_to_eat.queue_free()
						food_to_eat = null
				elif not movement.has_path():
					food_to_eat = null
			else:
				search_food()

func _get_transition(_delta):
	match state:
		states.wandering:
			if ant.is_working():
				return states.working
			elif ant.status.is_hungry() and timer_to_search_food < 0:
				return states.getting_food
		states.working:
			if not ant.is_working():
				if ant.status.is_hungry() and timer_to_search_food < 0:
					return states.getting_food
				return states.wandering
		states.getting_food:
			if not ant.status.is_hungry() and not is_instance_valid(food_to_eat):
				return states.wandering
			if timer_to_search_food > 0:
				return states.wandering

func wander():
	if movement.w_walking_to == null:
		movement.w_last_pos = ant.position
		var tile = ant.get_tile_position() + Vector2(randi()%3-1, randi()%3-1)
		if ant.tilemap.is_walkablev(tile):
			movement.w_walking_to = ant.tilemap.map_to_world_centered(tile)
#	if not movement.is_waiting_path():
#		movement.set_goal(ant.get_tile_position() + Vector2(randi()%10-5, randi()%10-5))

var timer_to_search_food = 0.0
func search_food():
	var storage_with_food = storage.closest_chunk_with_category(ant.get_tile_position(), "food")
	if storage_with_food:
		food_to_eat = storage_with_food.items[randi()%storage_with_food.items.size()]
		movement.set_goal(storage_with_food.tile)
		if not food_to_eat:
			print(ant.name, " found food but everything is held")
		eating_counter = 1.0
	if not food_to_eat:
		#print("we have no food in storage")
		timer_to_search_food = 1.0

func get_action():
	match state:
		states.wandering:
			return "wandering"
		states.working:
			if ant.is_working():
				return ant.job.status
			return "idling"
		states.getting_food:
			if is_instance_valid(food_to_eat):
				if ant.movement.on_same_tile(food_to_eat.position):
					return "eating"
				elif movement.has_path():
					return "getting food"
			return "searching food"


