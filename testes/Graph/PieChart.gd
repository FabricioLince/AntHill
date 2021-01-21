extends Node2D

export (Array) var data
export (float) var pie_radius = 64
export (float) var starting_angle = 0
export (bool) var fill = false
export (String) var label_format = "{label}:{amount}\n{percent_100.0}%"
var font
var right

var total
onready var pieces_node = $Pieces
var pieces = []
onready var labels = $Labels

func _ready():
	update()

func _process(_delta):
	right = Vector2.RIGHT * pie_radius # move to setter of pie_radius
	if data == null or data.size()==0:
		data = [
			{label="Collectors", amount=12.5, color=Color.blue},
			{label="Diggers", amount=3.14, color=Color.brown},
			{label="Nurses", amount=4, color=Color.pink},
		]
	if font == null:
		font = Control.new().get_font("font")
	
	recalculate()
	#update()
	create_pieces()

func create_pieces():
	assert_piece_amount()
	assert_label_amount()
	for i in range(data.size()):
		pieces[i].polygon = PoolVector2Array(create_points_for(data[i]))
		pieces[i].color = data[i].color
		
		set_label(i, data[i])

func set_label(i, data_point):
	var label = labels.get_child(i)
	label.text = label_format.format(data_point)
	label.rect_position = right.rotated(data_point.start_angle+data_point.arc/2)
	label.rect_size = Vector2(100, 100)

func create_points_for(data_point, arc_size=16):
	var points = []
	points.resize(2 + arc_size)
	points[0] = Vector2.ZERO
	for i in range(arc_size):
		points[2+i] = right.rotated(data_point.start_angle+data_point.arc/arc_size*i)
	points[points.size()-1] = right.rotated(data_point.end_angle)
	return points

func assert_piece_amount():
	while pieces.size() < data.size():
		var piece = Polygon2D.new()
		pieces_node.add_child(piece)
		pieces.push_back(piece)
	for i in range(data.size()):
		pieces[i].visible = true
	for i in range(data.size(), pieces.size()):
		pieces[i].visible = false

func assert_label_amount():
	while labels.get_child_count() < data.size():
		var label = RichTextLabel.new()
		label.modulate = Color.black
		label.size_flags_vertical = 2
		label.size_flags_horizontal = 2
		labels.add_child(label)
	for i in range(data.size(), labels.get_child_count()):
		labels.get_child(i).queue_free()

func recalculate():
	total = 0.0
	for d in data:
		if not is_valid_data(d): return false
		total += d.amount
	
	for d in data:
		d.percent = float(d.amount)/total
		d["percent_100.0"] = "%.1f"%(d.percent*100)
	
	var phi = deg2rad(starting_angle)
	for d in data:
		d.start_angle = phi
		d.arc = 2*PI*d.percent
		d.end_angle = d.start_angle+d.arc
		phi += d.arc

func old_draw():
	var points = PoolVector2Array()
	points.resize(19)
	points.set(0, Vector2.ZERO)
	for d in data:
		if not is_valid_data(d): return false
		if fill:
			if data.size() == 1:
				draw_circle(Vector2.ZERO, pie_radius, d.color)
			else:
				points.set(1, right.rotated(d.start_angle))
				for i in range(16):
					points.set(2+i, right.rotated(d.start_angle+d.arc/16*i))
				points.set(points.size()-1, right.rotated(d.start_angle+d.arc))
				draw_colored_polygon(points, d.color)
		else:
			draw_arc(Vector2.ZERO, pie_radius, d.start_angle, d.end_angle, 16, d.color)
			draw_line(Vector2.ZERO, right.rotated(d.start_angle), d.color)
	
	for d in data:
		if not is_valid_data(d): break
		d_string(right.rotated(d.start_angle+d.arc/2), "%s: %d"%[d.label, d.amount])
		d_string(right.rotated(d.start_angle+d.arc/2)+Vector2(0, 12), "%.1f%%"%[d.percent*100])
		

func d_string(pos, text, modulate=Color.black):
	draw_string(font, pos, text, modulate)

func is_valid_data(d):
	return d != null and d.has("amount") and d.has("label")
