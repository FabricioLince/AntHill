extends Node2D

onready var camera = $Camera2D
onready var tilemap = $Level/TileMap
onready var dig = $Level/Areas/Dig
onready var ant_manager = $Ants
onready var item_manager = $Items
onready var selector = $Selector
onready var collect_task_system = $TaskSystem/CollectTaskSystem
onready var storage = $Level/Areas/Storage
onready var nursary = $Level/Areas/Nursary
var current_level
var selected_ant = null

func _ready():
	current_level = $Level

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.scancode == KEY_SPACE:
				get_tree().paused = not get_tree().paused
			elif event.scancode == KEY_S:
				cycle_selection_mode()
				print(selector.ModeKind.keys()[selector.selection_mode])
			elif event.scancode == KEY_D:
				if selector.selection_mode == selector.ModeKind.TILES:
					mark_to_dig(selector.selected_tiles)
			elif event.scancode == KEY_F:
				if selector.selection_mode == selector.ModeKind.ITEMS:
					fetch_all(selector.selected_items)
			elif event.scancode == KEY_N:
				if selector.selection_mode == selector.ModeKind.TILES:
					create_nursary(selector.selected_tiles)
			elif event.scancode == KEY_ENTER:
				if selector.selection_mode == selector.ModeKind.TILES:
					create_storage(selector.selected_tiles)
			
			elif event.scancode == KEY_LEFT:
				camera.move(Vector2.LEFT * 32)
			elif event.scancode == KEY_RIGHT:
				camera.move(Vector2.RIGHT * 32)
			elif event.scancode == KEY_DOWN:
				camera.move(Vector2.DOWN * 32)
			elif event.scancode == KEY_UP:
				camera.move(Vector2.UP * 32)
			elif event.scancode == KEY_Q:
				if Engine.time_scale == 1.0:
					Engine.time_scale = 2.0
				else:
					Engine.time_scale = 1.0
			
			elif event.scancode == KEY_END:
				for item in selector.selected_items:
					print(item.type, " : ", item.stored_in)
			

func cycle_selection_mode():
	match selector.selection_mode:
		selector.ModeKind.ANTS:
			selector.selection_mode = selector.ModeKind.TILES
		selector.ModeKind.TILES:
			selector.selection_mode = selector.ModeKind.ITEMS
		selector.ModeKind.ITEMS:
			selector.selection_mode = selector.ModeKind.ANTS

func mark_to_dig(tiles):
	for tile in tiles:
		if dig.tiles.has(tile):
			dig.remove_tile(tile)
		elif not tilemap.is_walkablev(tile):
			dig.add_tile(tile)

func fetch_all(items):
	for item in items:
		if item == null or item.held or item.stored_in:
			continue
		if item.get("category") == "ant egg":
			continue
		collect_task_system.put_fetch_task(item)

func create_storage(tiles):
	if can_create_storage(tiles):
		storage.add_chunk(tiles)
		return true
	return false

func create_nursary(tiles):
	if can_create_storage(tiles):
		nursary.add_chunk(tiles)
		return true
	return false

func can_create_storage(tiles):
	for tile in tiles:
		if not tilemap.is_walkablev(tile):
			return false
		if storage.get_chunk_for(tile):
			return false
		if nursary.get_chunk_for(tile):
			return false
	return tiles.size() > 0
