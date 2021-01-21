extends "res://task system/TaskSystem.gd"

func get_closest_task(tile):
	var task = null
	var dist
	for t in tasks:
		var d = tile.distance_squared_to(t.tile)
		if task == null or d < dist:
			task = t
			dist = d
	if task:
		tasks.erase(task)
	return task

func put_dig_task(tile):
	var task = DigTask.new(tile)
	push_task(task)
	return task

class DigTask:
	signal done()
	var tile
	var valid
	func _init(tile_):
		self.tile = tile_
		self.valid = true
	func set_done():
		emit_signal("done", tile)
