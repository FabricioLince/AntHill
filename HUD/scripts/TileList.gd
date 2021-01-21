extends VBoxContainer

onready var label = $TilePanels/Label
onready var dig_button = $Buttons/Dig
onready var create_storage_button = $Buttons/CreateStorage
onready var create_nursary_button = $Buttons/CreateNursary

onready var tilemap = get_node("/root/Game/Level/TileMap")
onready var game = get_node("/root/Game")

var selected_tiles = []

var type_names = {0:"Ground", 1:"Dirt"}

func show_info(tiles):
	selected_tiles = tiles
	
	var count_by_type = {}
	for tile in tiles:
		var type = tilemap.get_cellv(tile)
		if not count_by_type.has(type):
			count_by_type[type] = []
		count_by_type[type].push_back(tile)
	
	label.text = ""
	for type in count_by_type:
		label.text += "%s (%d tiles)\n"%[type_names[type], count_by_type[type].size()]
	
	create_storage_button.visible = game.can_create_storage(tiles)
	create_nursary_button.visible = game.can_create_storage(tiles)
	
	if tiles.size() == 0:
		dig_button.visible = false
	elif count_by_type.has(1):
		dig_button.visible = true
	else:
		dig_button.visible = false


func _on_Dig_pressed():
	game.mark_to_dig(selected_tiles)


func _on_CreateStorage_pressed():
	game.create_storage(selected_tiles)


func _on_CreateNursary_pressed():
	game.create_nursary(selected_tiles)
