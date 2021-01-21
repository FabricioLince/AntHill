extends "res://task system/TaskSystem.gd"

func put_egg_task(egg):
	push_task(EggTask.new(egg))

func push_fetch_task(egg):
	push_task(EggTask.new(egg))

func push_feed_task(egg):
	push_task(EggTask.new(egg, true))
	return tasks[-1]

class EggTask:
	extends "res://task system/TaskSystem.gd".BaseTask
	var valid setget set_, is_valid
	func is_valid():
		return is_instance_valid(item)
	var item setget set_
	func set_(_a):pass
	var to_feed = false
	func _init(item_node, to_feed_=false):
		item = item_node
		to_feed=to_feed_
