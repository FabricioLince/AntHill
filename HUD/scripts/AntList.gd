extends VBoxContainer

export (PackedScene) var AntPanel

onready var panels_node = $AntPanels

var panels = []

func show_info(ants):
	assert_panel_amount(ants.size())
	
	var index = 0
	for ant in ants:
		if ant == null: continue
		var panel = panels[index]
		index += 1
		panel.ant = ant

func assert_panel_amount(amount):
	while panels.size() < amount:
		var panel = AntPanel.instance()
		panels_node.add_child(panel)
		panels.push_back(panel)
	while panels.size() > amount:
		panels[-1].queue_free()
		panels.pop_back()
