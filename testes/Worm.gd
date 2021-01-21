extends Node2D

onready var head = $Head
onready var sections = $Sections.get_children()
onready var line = $Line2D

var move_speed = 100
var timer = 0.0
var tps = 0.25 # time per section
var total_time

var dist_between_sections = 16.0

var sections_timing = []
var head_timing = {}

func _ready():
	total_time = tps/2 * sections.size() + tps
	
	var n = sections.size()
	for i in range(n):
		sections_timing.push_back({start=tps*(n-i-1)/2, end=tps*(n-i+1)/2})
		sections[i].position = head.position + Vector2.LEFT.rotated(head.rotation)*dist_between_sections*(i+1)
#		print("section ", i)
#		print("start tps*%d/2"%(n-i-1))
#		print("end tps*%d/2"%(n-i+1))
	head_timing.start=tps*n/2
	head_timing.end=tps*(n+2)/2
#	print("head")
#	print("start tps*%d/2"%(n))
#	print("end tps*%d/2"%(n+2))
	line.clear_points()
	line.add_point(head.position)
	for i in range(n):
		line.add_point(sections[i].position)

func _process(delta):
	timer += delta
	if timer > total_time:
		timer -= total_time
	
	#var next = 
	for i in range(sections.size()):
		line.set_point_position(i+1, sections[i].position)
		if timer > sections_timing[i].start and timer < sections_timing[i].end:
			var target = line.get_point_position(i)
			target = (target - sections[i].position)
			var speed = move_speed * target.length() / dist_between_sections
			sections[i].rotation = lerp_angle(sections[i].rotation, target.angle(), delta/0.5)
			sections[i].position += Vector2.RIGHT.rotated(sections[i].rotation)*speed*delta
	
	line.set_point_position(0, head.position)
	if timer > head_timing.start and timer < head_timing.end:
		var target = get_global_mouse_position()
		var direction_to_target = target - head.global_position
		head.rotation = lerp_angle(head.rotation, direction_to_target.angle(), delta/0.5)
		head.position += Vector2.RIGHT.rotated(head.rotation) * move_speed*delta
