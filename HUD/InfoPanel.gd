extends Panel

onready var game = get_node("/root/Game")
onready var mouse = get_node("/root/Game/Mouse")
onready var storage = get_node("/root/Game/Level/Areas/Storage")
onready var selector = get_node("/root/Game/Selector")
onready var item_list = get_node("/root/Game/MainHUD/SelectionList/ItemList")
onready var ant_list = get_node("/root/Game/MainHUD/SelectionList/AntList")

var selected_chunk : Object

func _ready():
	var _a = selector.connect("selection_changed", self, "on_selection_changed")

func _process(_delta):
	match selector.selection_mode:
		selector.ModeKind.ANTS:
			show_ants_info(selector.selected_ants)
		selector.ModeKind.ITEMS:
			show_items_info(selector.selected_items)

func on_selection_changed(mode, selected):
	if selected_chunk:
		selected_chunk.selected = false
		selected_chunk.disconnect("amount_changed", self, "on_amount_change")
		selected_chunk = null
	match mode:
		selector.ModeKind.ANTS:
			show_ants_info(selected)
		selector.ModeKind.ITEMS:
			show_items_info(selected)
		selector.ModeKind.TILES:
			if selected.size() == 1:
				show_storage_info(selected[0])

func show_storage_info(tile):
	selected_chunk = storage.get_chunk_for(tile)
	if selected_chunk:
		selected_chunk.selected = true
		var _a = selected_chunk.connect("amount_changed", self, "on_amount_change")
	update_chunk_info()

func on_amount_change(_i, _t, _a):
	update_chunk_info()

func update_chunk_info():
	if selected_chunk:
		var count_by_type = selected_chunk.get_count_by_type()
		var item_count = selected_chunk.get_total_amount()
		$Label.text = "Storage:\n"+\
		str(item_count) + " items\n"
		for type in count_by_type:
			$Label.text += str(type)+": "+str(count_by_type[type].count)+"/"+str(count_by_type[type].max)+"\n"
		var total = selected_chunk.tiles.size()
		$Label.text += str(total-selected_chunk.get_empty_tiles().size())+"/"+str(total) + " occupied tiles\n"
	else:
		$Label.text = ""

const ant_info_format = "{name}: {job}\n<{action}>\nAge: {age} days old\nFood: {food_bar} {food_percent}%\nHealth: {health_percent}%\n"
func show_ants_info(ants):
	ant_list.show_info(ants)

func old_show_ants(ants):
	var full_text = ""
	for ant in ants:
		if ant == null: continue
		var info = {}
		info["name"] = ant.name
		info["action"] = ant.get_action()
		if ant.job:
			info["job"] = ant.job.job_name
		else:
			info["job"] = "Jobless"
		info["age"] = "%.1f"%[ant.status.age_in_days()]
		
		var food_bar = "["
		var bar_amount = (ceil(ant.status.food_percentage()*10))
		for _i in range(bar_amount):
			food_bar += "#"
		for _i in range(10-bar_amount):
			food_bar += "_"
		food_bar += "]"
		info["food_bar"] = food_bar
		info["food_percent"] = "%.1f"%(ant.status.food_percentage()*100)
		info["health_percent"] = "%.0f"%(ant.status.health*100)
		
		full_text += ant_info_format.format(info)
		full_text += "waiting path: "+str(ant.movement.is_waiting_path())+"\n"
		full_text += "\n"
	$Label.text = "Ants:\n"+full_text

const item_info_format = "{name} [{category}] X {amount}\n"
func show_items_info(items):
	item_list.show_info(items)

func foo(items):
	var count_by_type = {}
	for item in items:
		if item == null: continue
		if not count_by_type.has(item.type):
			count_by_type[item.type] = {category=item.get("category"), amount=0, list=[]}
		count_by_type[item.type].amount += 1
		count_by_type[item.type].list.append(item)
	
	var full_text = ""
	for type in count_by_type:
		full_text += item_info_format.format({
			name = type, 
			category = count_by_type[type].category, 
			amount = count_by_type[type].amount
		})
		#if item.held: full_text += "held by %s\n"%[item.held.name]
		#if item.has_method("get_info"): full_text += item.get_info()+"\n"
	$Label.text = "Items:\n" + full_text
