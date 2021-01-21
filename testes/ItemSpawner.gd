extends Node

export (PackedScene) var Item
onready var items_root = get_node("/root/Game/Items")
export (int) var max_amount = 5
export (float) var wait_time = 1.0
export (float) var min_distance = 2.0
export (NodePath) var task_system
var last_item_spawned = {}
var timer = {}

func _process(delta):
	for point in get_children():
		if not point is Position2D:
			continue
		
		if not timer.has(point):
			timer[point] = wait_time
		timer[point] -= delta
		if timer[point] < 0:
			timer[point] += wait_time
		else:
			continue
		
		var items = last_item_spawned.get(point, [])
		
		for item in items:
			if item == null or item.position.distance_squared_to(point.global_position) > min_distance*min_distance:
				last_item_spawned[point].erase(item)
		
		if items.size() >= max_amount:
			continue
		
		var item = Item.instance()
		item.position = point.global_position + (Vector2.ONE * rand_range(0, min_distance/2)).rotated(rand_range(0, 2*PI))
		item.rotation = rand_range(0, 2*PI)
		items_root.add_child(item)
		if task_system:
			get_node(task_system).put_fetch_task(item)
		if not last_item_spawned.has(point):
			last_item_spawned[point] = []
		last_item_spawned[point].append(item)
