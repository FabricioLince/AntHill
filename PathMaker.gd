extends Node

var queue = []

onready var map = get_node("/root/Game/Level/TileMap")

func request_path(from, to, requester):
	queue.append({from=from, to=to, requester=requester})

func _process(_delta):
	if queue.size() > 0:
		var r = queue.pop_front()
		if r.requester:
			var path = map.find_path(r.from, r.to)
			r.requester.answer_request(r, path)

