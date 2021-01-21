tool
extends Node2D

export (Array) var data
export (float) var pie_radius = 64
export (float) var starting_angle = 0
export (bool) var fill = false
var font

var total
var points = PoolVector2Array()

func _ready():
	points.resize(19) # origin + arc start + 16 on arc + arc end
	points.set(0, Vector2.ZERO)

func _process(delta):
	points.resize(19) # origin + arc start + 16 on arc + arc end
	points.set(0, Vector2.ZERO)
	if data == null or data.size()==0:
		data = [
			{label="Collectors", amount=12, color=Color.blue},
			{label="Diggers", amount=3, color=Color.brown},
			{label="Nurses", amount=4, color=Color.pink},
		]
	if font == null:
		font = Control.new().get_font("font")
	#starting_angle += delta*10
	recalculate()
	update()

func recalculate():
	total = 0
	for d in data:
		if not is_valid_data(d): break
		total += d.amount
	
	var p = Vector2(0, 12)
	for d in data:
		if not is_valid_data(d): break
		d.percent = float(d.amount)/total
		#d_string(p, "%s = %.1f%%"%[str(d.label), d.percent*100])
		p+=Vector2(0, 12)
	
	var phi = deg2rad(starting_angle)
	for d in data:
		if not is_valid_data(d): break
		d.start_angle = phi
		d.arc = 2*PI*d.percent
		d.end_angle = d.start_angle+d.arc
		phi += d.arc

func _draw():
	var right = Vector2.RIGHT*pie_radius
	
	for d in data:
		if not is_valid_data(d): break
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
