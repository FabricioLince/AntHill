extends Node2D

signal click(pos, button)
signal drag(origin, current, delta, button)
signal select(rect, button)

onready var game = get_node("/root/Game")

var w_click_down_pos
var click_down_mask
var select_rect = Rect2(0, 0, 0, 0)

func _ready():
	var _a = connect("select", self, "on_select")
	_a = connect("drag", self, "on_drag")

func on_select(_rect, _button):
	update()

func on_drag(origin, current, delta, button):
	if button == BUTTON_MASK_LEFT:
		select_rect.position.x = min(origin.x, current.x)
		select_rect.position.y = min(origin.y, current.y)
		select_rect.size.x = abs(current.x - origin.x)
		select_rect.size.y = abs(current.y - origin.y)
		update()
	elif button == BUTTON_MASK_MIDDLE:
		game.camera.move(-delta)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			#print("mouse down ", event.button_mask)
			w_click_down_pos = get_global_mouse_position()
			click_down_mask = event.button_mask
		elif w_click_down_pos:
			#print("mouse up ", click_down_mask)
			if w_click_down_pos.distance_to(get_global_mouse_position()) < 4:
				emit_signal("click", w_click_down_pos, click_down_mask)
			else:
				emit_signal("select", select_rect, click_down_mask)
			w_click_down_pos = null
	elif event is InputEventMouseMotion:
		if w_click_down_pos:
			#print("mouse drag ", event.button_mask)
			if click_down_mask == event.button_mask:
				emit_signal("drag", w_click_down_pos, get_global_mouse_position(), event.relative, event.button_mask)
func _draw():
	if w_click_down_pos:
		draw_rect(select_rect, Color.white, false)
