extends Node
class_name StateMachine

signal state_changed(new_state, old_state)

var state = null setget set_state
var previous_state = null
var states = {}

onready var parent = get_parent()

func _physics_process(delta):
	if state:
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition:
			set_state(transition)

func _state_logic(_delta):
	pass

func _get_transition(_delta):
	return null

func _enter_state(_new_state, _old_state):
	pass

func _exit_state(_old_state, _new_state):
	pass

func set_state(new_state):
	previous_state = state
	state = new_state
	#print("setting state to ", state_name())
	
	if previous_state:
		_exit_state(previous_state, new_state)
	if new_state:
		_enter_state(new_state, previous_state)
	
	emit_signal("state_changed", new_state, previous_state)

func add_state(state_name):
	states[state_name] = states.size()+1

func state_name():
	if state:
		for k in states:
			if states[k] == state:
				return k
	return "null"
