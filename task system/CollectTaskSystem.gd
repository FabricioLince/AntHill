extends "res://task system/TaskSystem.gd"


func put_fetch_task(item):
	push_task(CollectTask.new(item))

class CollectTask:
	var valid setget set_, is_valid
	func is_valid():
		return item.get_ref() != null
	var item setget set_, get_item
	func set_(_a):pass
	func get_item(): return item.get_ref()
	func _init(item_node):
		item = weakref(item_node)
