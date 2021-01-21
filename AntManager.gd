extends Node

var Ant = preload("res://ant/Ant.tscn")

var jobs = {"Collector":Collector, "Digger":Digger, "Nurse":Nurse}

var ants = {}
var ants_by_job = {}
var counter = 1

export (Dictionary) var starting_ants = {"Collector":5, "Digger":1, "Nurse":1}
var starting_sum = 0
onready var queen = get_node("/root/Game/Queen")

func get_by_id(id):
	return ants.get(id)
func get_by_job(job):
	return ants_by_job.get(job, [])

func _ready():
	for c in get_children():
		register_ant(c)
	yield(get_tree(), "idle_frame")
	for job_name in starting_ants:
		starting_sum += starting_ants[job_name]
		for _i in starting_ants[job_name]:
			spawn_ant(queen.position, job_name)

func spawn_random_ant(pos):
	if starting_sum > 0:
		var base_ant_value = float(ants.size()) / starting_sum
		for job in starting_ants:
			var expected = base_ant_value * starting_ants[job]
			if expected > ants_by_job[job].size():
				spawn_ant(pos, job)
				return
	
	return spawn_ant(pos, jobs.keys()[randi()%jobs.keys().size()])

func spawn_ant(pos, job_name):
	var ant = Ant.instance()
	ant.name = "ant#%d"%counter
	counter += 1
	ant.position = pos
	ant.rotation = rand_range(0, 2*PI)
	var job = jobs[job_name].new()
	ant.add_child(job)
	add_child(ant)
	
	register_ant(ant)

func register_ant(ant):
	var id = _get_next_id()
	ant._id = id
	ants[id] = weakref(ant)
	ant.connect("dead", self, "on_ant_dead")
	if ant.job:
		if not ants_by_job.has(ant.job.job_name):
			ants_by_job[ant.job.job_name] = {}
		ants_by_job[ant.job.job_name][id] = ant

func _get_next_id():
	for i in range(999999):
		if not ants.has(i) or ants[i].get_ref() == null:
			return i
	push_error("Too many ants")

func on_ant_dead(ant):
	ant.disconnect("dead", self, "on_ant_dead")
	var corpse = preload("res://item/AntCorpse.tscn").instance()
	corpse.position = ant.position
	corpse.rotation = ant.rotation
	var item_manager = get_node("/root/Game/Items")
	item_manager.add_child(corpse)
	ants.erase(ant._id)
	if ant.job:
		ants_by_job[ant.job.job_name].erase(ant._id)
