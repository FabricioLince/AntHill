extends Node2D

signal dead(ant)

var _id

onready var tilemap = get_node("/root/Game/Level/TileMap")
onready var movement = $Movement
onready var hud = $HUD
onready var status = $Status
onready var state_machine = $StateMachine

var job = null setget set_, get_job
func set_(_a): pass
func get_job(): 
	if not job:
		for j in get_children():
			if j.get("is_job"):
				job = j
				break
	return job

func get_action():
	return state_machine.state_name()+":"+state_machine.get_action()

func is_working():
	return get_job() and job.get_status()

var selected = false setget set_selected
func set_selected(s):
	selected = s
	update()

export (float) var move_speed = 5.0 setget set_move_speed
func set_move_speed(mv):
	move_speed = mv
	$Movement.walk_speed = mv

func _draw():
	if selected:
		draw_circle(Vector2.ZERO, 16, Color.white)

func get_tile_position():
	return tilemap.world_to_map(position)

func die():
	emit_signal("dead", self)
	queue_free()

const is_ant = true
