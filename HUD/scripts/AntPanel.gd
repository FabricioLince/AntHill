extends HBoxContainer

onready var collapsed_main_label = $Collapsed/VBoxContainer/MainLabel
onready var collapsed_age = $Collapsed/VBoxContainer/Stats/AgeText
onready var collapsed_hunger = $Collapsed/VBoxContainer/Stats/HungerText
onready var collapsed_health = $Collapsed/VBoxContainer/Stats/HealthText

var ant 

var ant_name : String setget set_ant_name
func set_ant_name(n):
	ant_name = n
	update_main_label()

var job_name = "" setget set_ant_job
func set_ant_job(job):
	job_name = job
	update_main_label()

func update_main_label():
	collapsed_main_label.text = ant_name+":"+job_name

var age : float setget set_age
func set_age(age_):
	age = age_
	collapsed_age.text = "%.1f"%age

var hunger : float setget set_hunger
func set_hunger(hunger_):
	hunger = hunger_
	collapsed_hunger.text = "%.0f"%hunger

var health : float setget set_health
func set_health(health_):
	health = health_
	collapsed_health.text = "%.0f"%health

func _process(_delta):
	if ant:
		self.ant_name = ant.name
		if ant.job:
			self.job_name = ant.job.job_name
		else:
			self.job_name = "Jobless"
		self.age = ant.status.age_in_days()
		self.hunger = ant.status.food_percentage()*100
		self.health = ant.status.health*100
