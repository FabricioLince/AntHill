extends VBoxContainer

export (PackedScene) var ItemPanel

onready var panels_node = get_node("ItemPanels")
onready var fetch_button = $Buttons/FetchAll

var panels = []
var selected_items

func show_info(items):
	selected_items = items
	var count_by_type = {}
	for item in items:
		if item == null: continue
		if not count_by_type.has(item.type):
			count_by_type[item.type] = {category=item.get("category"), amount=0, list=[]}
		count_by_type[item.type].amount += 1
		count_by_type[item.type].list.append(item)
	
	assert_panel_amount(count_by_type.size())
	
	var index = 0
	for type in count_by_type:
		var panel = panels[index]
		index += 1
		panel.description = "%s\n(%s)"%[type, count_by_type[type].category]
		panel.amount = count_by_type[type].amount
		panel.icon = count_by_type[type].list[0].icon
	
	fetch_button.visible = items.size() > 0
	

func assert_panel_amount(amount):
	while panels.size() < amount:
		var panel = ItemPanel.instance()
		panels_node.add_child(panel)
		panels.push_back(panel)
	while panels.size() > amount:
		panels[-1].queue_free()
		panels.pop_back()


func _on_FetchAll_pressed():
	get_node("/root/Game").fetch_all(selected_items)
