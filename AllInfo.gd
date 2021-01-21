extends Label

onready var ant_manager = get_node("/root/Game/Ants")
onready var item_manager = get_node("/root/Game/Items")
onready var c_task_system = get_node("/root/Game/TaskSystem/CollectTaskSystem")
onready var egg_task_system = get_node("/root/Game/TaskSystem/NewEggTaskSystem")
onready var dig_task_system = get_node("/root/Game/TaskSystem/DigTaskSystem")
onready var path_maker = get_node("/root/Game/PathMaker")


func _process(_delta):
	
	var ant_jobs = ""
	for job in ant_manager.ants_by_job:
		ant_jobs += "> "+ job+": "+str(ant_manager.ants_by_job[job].size())+"\n"
	
	text = "Ant Hill\n" \
	+ "Pop: "+ str(ant_manager.get_child_count())+" ants\n" \
	+ ant_jobs \
	+ "Eggs: " + str(item_manager.get_by_category("ant egg").size()) +" \n"\
	+ "Collect tasks: " + str(c_task_system.tasks.size()) +"\n"\
	+ "Dig tasks: " + str(dig_task_system.tasks.size()) +"\n"\
	+ "Egg tasks: " + str(egg_task_system.tasks.size()) +"\n"\
	+ "Paths requests: " + str(path_maker.queue.size()) + "\n"\
	
	
