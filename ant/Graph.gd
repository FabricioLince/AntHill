extends Node2D

onready var manager = get_parent()
var bar_w = 8

func _process(_delta):
	if visible:
		update()

func _draw():
	var bars = {}
	var maxi = 0
	for ant in manager.ants.values():
		var health = int(ceil(ant.status.food_percentage()*100))
		if not bars.has(health):
			bars[health] = 0
		bars[health] += 1
		maxi = max(maxi, bars[health])
	
	for i in range(101):
		if not bars.has(i):
			continue
		var rect = Rect2(50+i*bar_w, maxi*10+50, bar_w, -bars[i]*10)
		draw_rect(rect, Color.blue, true)
