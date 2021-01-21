extends "res://Area.gd"

onready var task_system = get_node("/root/Game/TaskSystem/DigTaskSystem")

var tasks = {}

var tiles_wo_task = []

func _ready():
	color = Color.red
	var _a = connect("tile_added", self, "on_add")
	_a = connect("tile_removed", self, "on_remove")

func on_add(tile):
	if not add_task_if_can(tile):
		tiles_wo_task.append(tile)

func on_remove(tile):
	if tasks.has(tile):
		task_system.remove_task(tasks[tile])
		tasks[tile].valid = false
		for tile in tiles_wo_task:
			add_task_if_can(tile)
		for tile in tasks:
			if tiles_wo_task.has(tile):
				tiles_wo_task.erase(tile)
		tasks.erase(tile)
	elif tiles_wo_task.has(tile):
		tiles_wo_task.erase(tile)

func add_task_if_can(tile):
	if has_walkable_neighbor(tile):
		var task = task_system.put_dig_task(tile)
		tasks[tile] = tasks
		task.connect("done", self, "remove_tile_by_task")
		return task

func remove_tile_by_task(task, _db):
	remove_tile(task.tile)

func has_walkable_neighbor(tile):
	return tilemap.get_walkable_neighbors(tile).size() > 0
