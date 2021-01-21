extends Node

onready var ant = get_parent()

const seconds_in_day = 60.0

var age = 0.0

var food = 100.0
var max_food = 100.0
var food_deplet_rate = 1

var health = 1.0
var health_deplet_by_starvation = 0.01

func _ready():
	food_deplet_rate += rand_range(-0.005, +0.005)

func _process(delta):
	age += delta
	food = max(0, food - delta*food_deplet_rate)
	if is_starving():
		health = max(0, health - delta*health_deplet_by_starvation)
		if health <= 0:
			ant.die()

func age_in_days():
	return age / seconds_in_day

func food_percentage():
	return food / max_food

func is_hungry():
	return food_percentage() < 0.25

func is_starving():
	return food <= 0.001

func food_status():
	if is_starving():
		return "starving"
	if is_hungry():
		return "hungry"
	return "saciated"
