extends Node2D

onready var head = $Head
onready var sections = $Sections.get_children()
onready var line = $Line2D

var amount_sections = 32
var move_speed = 100
var tps = 0.5 # time per section
var delay = 0.1 # delay percent of tps
var dist_between_sections = 16.0
var timer_amount = 3
var delay_between_timers = 1.0

var _total_time
var _sections_timing = []
var _head_timing = {}
var _timers = []

func _ready():
	assert_section_amount()
	setup_timing()
	for i in range(timer_amount):
		var timer = Timer.new()
		timer.wait_time = _total_time
		add_child(timer)
		_timers.append(timer)
# warning-ignore:return_value_discarded
		get_tree().create_timer(delay_between_timers*i).connect("timeout", self, "start_timer", [i])

func start_timer(i):
	_timers[i].start()

func assert_section_amount():
	while sections.size() < amount_sections:
		var n2d = Node2D.new()
		$Sections.add_child(n2d)
		sections = $Sections.get_children()

func setup_timing():
	var n = amount_sections
	
	for i in range(n):
		sections[i].position = head.position + Vector2.LEFT.rotated(head.rotation)*dist_between_sections*(i+1)
	line.clear_points()
	line.add_point(head.position)
	for i in range(n):
		line.add_point(sections[i].position)
	
	_sections_timing.resize(n)
	var delay_time = delay * tps
	for i in range(n):
		var ivi = (n-i-1)
		var start = delay_time*ivi
		var end = start + tps
		_sections_timing[i] = {start = start, end = end}
	
	_head_timing.start = delay_time*n
	_head_timing.end = _head_timing.start+tps
	_total_time = _head_timing.end

func _process(delta):
	for timer in _timers:
		move_sections(_total_time-timer.time_left, delta)

func move_sections(timer, delta):
	for i in range(amount_sections):
		line.set_point_position(i+1, sections[i].position)
		if timer > _sections_timing[i].start and timer < _sections_timing[i].end:
			var target = line.get_point_position(i)
			target = (target - sections[i].position)
			var l = target.length()
			var speed = move_speed
			#sections[i].modulate = Color.white
			if l < dist_between_sections:
				speed = 0
				#sections[i].modulate = Color.black
			if i < sections.size()-1:
				if line.get_point_position(i+1).distance_to(line.get_point_position(i+2)) > dist_between_sections*2:
					speed = 0
					#sections[i].modulate = Color.red
			sections[i].rotation = lerp_angle(sections[i].rotation, target.angle(), delta/0.5)
			sections[i].position += Vector2.RIGHT.rotated(sections[i].rotation)*speed*delta
	
	line.set_point_position(0, head.position)
	if timer > _head_timing.start and timer < _head_timing.end:
		var target = get_global_mouse_position()
		var direction_to_target = target - head.global_position
		if line.get_point_position(0).distance_to(line.get_point_position(1))>dist_between_sections*2:
			pass
		else:
			head.rotation = lerp_angle(head.rotation, direction_to_target.angle(), delta/0.5)
			head.position += Vector2.RIGHT.rotated(head.rotation) * move_speed*delta
