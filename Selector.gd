extends Node2D

signal selection_changed(mode, selected)
signal mode_changed(mode)

onready var mouse = get_node("/root/Game/Mouse")
onready var game = get_node("/root/Game")

enum ModeKind {ANTS, TILES, ITEMS}
var selection_mode = ModeKind.ANTS setget set_mode
func set_mode(m):
	if m != selection_mode:
		clear_all_selection()
	selection_mode = m
	emit_signal("mode_changed", selection_mode)

var selected_ants = []
var selected_tiles = []
var selected_items = []
var w_first_tile
var w_selection_size

func _ready():
	mouse.connect("select", self, "_on_mouse_select")
	mouse.connect("click", self, "_on_mouse_click")

func _on_mouse_click(pos, button):
	if button != BUTTON_MASK_LEFT:
		return
	clear_all_selection()
	match selection_mode:
		ModeKind.ANTS:
			game.selected_ant = null
			for ant in game.get_node("Ants").get_children():
				ant.selected = false
				if game.selected_ant == null:
					if ant.position.distance_to(pos) < 16:
						ant.selected = true
						game.selected_ant = ant
						selected_ants.append(ant)
			emit_signal("selection_changed", selection_mode, selected_ants)
		ModeKind.TILES:
			var tile = game.current_level.tilemap.world_to_map(pos)
			selected_tiles.append(tile)
			w_first_tile = game.current_level.tilemap.map_to_world(tile)
			w_selection_size = game.current_level.tilemap.cell_size
			emit_signal("selection_changed", selection_mode, selected_tiles)
		ModeKind.ITEMS:
			for item in game.get_node("Items").get_children():
				item.selected = false
				if item.position.distance_to(pos) < 16:
					item.selected = true
					selected_items.append(item)
			emit_signal("selection_changed", selection_mode, selected_items)
	
	update()

func _on_mouse_select(rect, button_mask):
	if button_mask != BUTTON_MASK_LEFT:
		return
	clear_all_selection()
	match selection_mode:
		ModeKind.ANTS:
			select_ants(rect)
			emit_signal("selection_changed", selection_mode, selected_ants)
		ModeKind.TILES:
			select_tiles(rect)
			emit_signal("selection_changed", selection_mode, selected_tiles)
		ModeKind.ITEMS:
			select_items(rect)
			emit_signal("selection_changed", selection_mode, selected_items)
	update()

func select_ants(rect):
	selected_ants.clear()
	for ant in game.get_node("Ants").get_children():
		ant.selected = false
		if rect.has_point(ant.position):
			selected_ants.append(ant)
			ant.selected = true
			game.selected_ant = ant
	return selected_ants

func select_tiles(rect):
	selected_tiles.clear()
	var map = game.current_level.tilemap
	var first_tile = map.world_to_map(rect.position)
	var last_tile = map.world_to_map(rect.position+rect.size)
	w_first_tile = map.map_to_world(first_tile)
	w_selection_size = map.map_to_world(last_tile)-w_first_tile+map.cell_size
	
	for x in range(first_tile.x, last_tile.x+1):
		for y in range(first_tile.y, last_tile.y+1):
			selected_tiles.append(Vector2(x, y))
	return selected_tiles

func select_items(rect):
	selected_items.clear()
	for item in game.get_node("Items").get_children():
		item.selected = false
		if rect.has_point(item.position):
			selected_items.append(item)
			item.selected = true
	return selected_items

func clear_all_selection():
	for ant in selected_ants:
		if ant:
			ant.selected = false
	selected_ants.clear()
	
	selected_tiles.clear()
	w_first_tile = null
	
	for item in selected_items:
		if item:
			item.selected = false
	selected_items.clear()

func _draw():
	if w_first_tile:
		draw_rect(Rect2(w_first_tile, w_selection_size), Color(1, 1, 1, 0.5), true)
