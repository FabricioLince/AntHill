extends Node2D

onready var map = get_parent()
onready var tilemap = get_node("/root/Game/Level/TileMap")

export (float) var move_speed = 50.0

var target_tile
var w_target
var path
var next_point
var direction

func _ready():
	var _a = get_node("/root/Game/Mouse").connect("click", self, "on_click")

func on_click(pos, button):
	if button == BUTTON_MASK_LEFT:
		target_tile = tilemap.world_to_map(pos)
		w_target = pos
		path = map.find_point_path(tilemap.world_to_map(position), target_tile)
		if path:
			path.remove(0)
		next_point = null
		update()

func _process(delta):
	if next_point:
		position += direction * move_speed * delta
		if position.distance_squared_to(next_point) < 4:
			next_point = null
	else:
		if path:
			next_point = path[0]
			direction = (next_point-position).normalized()
			$Sprite.rotation = direction.angle()
			path.remove(0)
			next_pos = next_point 
			last_pos = position
	
	update()

var last_pos
var next_pos
func _draw():
	if next_pos and last_pos: 
		draw_line(last_pos-position, next_pos-position, Color.black, 3)
