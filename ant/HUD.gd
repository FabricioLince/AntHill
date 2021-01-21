extends Node2D

onready var ant = get_parent()
onready var path_line = get_node("../Movement/Line2D")

onready var font = Control.new().get_font("font")
var panel_text = ""

func _process(_delta):
	path_line.visible = ant.selected
	$Panel.visible = ant.selected
	
	if ant.selected:
		update_path_line()
		update_panel()
	rotation = -ant.rotation

func update_panel():
	panel_text = ant.name
	
	$Panel/Label.text = panel_text
	$Panel.rect_size = $Panel/Label.rect_size

func update_path_line():
	if ant.movement.path == null:
		path_line.clear_points()
	elif path_line.get_point_count() != ant.movement.path.size()+1:
		path_line.clear_points()
		path_line.add_point(ant.position)
		for p in ant.movement.path:
			path_line.add_point(p)
	elif path_line.get_point_count() > 0:
		path_line.set_point_position(0, ant.position)
