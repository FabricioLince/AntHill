extends "res://item/Item.gd"

const category = "ant egg"

var age = 0.0

var time_to_mature = 100.0
var asked_for_food = false
var food = 0.0
var task_system

func _ready():
	$Sprite/ant.rotation = rand_range(0, 2*PI)
	$Tween.interpolate_property($Sprite, "scale", Vector2(0.05, 0.05), Vector2(0.3, 0.3), time_to_mature)
	$Tween.interpolate_property($Sprite/ant, "self_modulate", Color(1, 1, 1, 0), Color(0, 0, 0, 1), time_to_mature)
	$Tween.start()

func _process(delta):
	age += delta
	if maturation() >= 1:
		var ant_manager = get_node("/root/Game/Ants")
		ant_manager.spawn_random_ant(position)
		queue_free()
	if maturation() > 0.5 and not asked_for_food:
		task_system.push_feed_task(self)
		asked_for_food = true

func is_mature():
	return age > time_to_mature

func maturation():
	return min(1.0, age / time_to_mature)

func get_info():
	return "maturation %.1f%%"%[maturation()*100]

func get_icon():
	return $icon.texture
