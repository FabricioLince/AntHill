extends Node

var tasks = []

func get_task():
	if tasks.size() > 0:
		var task = tasks[0]
		tasks.remove(0)
		return task
	return null

func push_task(task):
	tasks.append(task)

func remove_task(task):
	tasks.erase(task)
