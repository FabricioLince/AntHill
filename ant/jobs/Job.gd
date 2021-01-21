extends StateMachine

onready var ant = get_parent()
onready var movement = get_node("../Movement")

var status = null setget set_, get_status
func set_(_a): pass
func get_status(): return status

const is_job = true

func work(delta):
	if state == states.idle:
		status = null
	else:
		status = state_name()
	_physics_process(delta)
