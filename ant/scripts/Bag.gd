extends Node

onready var ant = get_parent()

var holding setget set_holding, get_holding
func set_holding(item):
	if is_holding(): holding.held = null
	holding = item
	if is_holding(): holding.held = self
func get_holding():
	return holding
func is_holding():
	return is_instance_valid(holding)

func hold(item):
	if not is_instance_valid(item): return false
	if item.held: return false
	item.withdraw()
	set_holding(item)
	return is_holding()
func drop():
	set_holding(null)

func _process(_delta):
	if is_holding():
		holding.position = ant.position
		holding.rotation = ant.rotation
