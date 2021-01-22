extends Node2D

signal amount_changed(item, tile, new_amount)
signal item_deposited(item, tile)

var map 
var tiles = [] # [tile_pos, tile_pos]
var storage = {} # storage[tile_pos] = [item_node, item_node]

var restriction_type = null

var color = Color.green

var selected = false setget set_selected
func set_selected(s):
	selected = s
	update()
var highlighted = false setget set_h
func set_h(h):
	highlighted = h
	update()

func _ready():
	update()

func add_tile(pos):
	tiles.append(pos)
	storage[pos] = []
	update()
func remove_tile(pos):
	tiles.erase(pos)
	storage.erase(pos)
	update()

func get_total_amount():
	var s = 0
	for tile in tiles:
		s += amount_on(tile)
	return s
func get_count_by_type():
	var count_by_type = {}
	for tile in tiles:
		var type = type_on(tile)
		if type:
			if not count_by_type.has(type):
				count_by_type[type] = {count=0, max=0}
			count_by_type[type].count += amount_on(tile)
			count_by_type[type].max += max_stack_for(tile)
	return count_by_type
func get_empty_tiles():
	var empty = []
	for tile in tiles:
		if amount_on(tile) == 0:
			empty.append(tile)
	return empty
func get_available_tile_for(item):
	for tile in tiles:
		if can_put_on(item, tile):
			return tile

func can_put_on(item, tile):
	if item == null or not tiles.has(tile) or not item.get("is_item"):
		return false
	if not type_compatible(item):
		return false
	if amount_on(tile) == 0:
		return true
	if (storage[tile][0].type == item.type and \
		amount_on(tile) < max_stack_for(tile)):
			return true

func type_compatible(item):
	return \
	restriction_type == null or \
	restriction_type != null and item.type == restriction_type

func items_on(tile):
	return storage.get(tile, [])
func amount_on(tile):
	return storage.get(tile, []).size()
func type_on(tile):
	if amount_on(tile) > 0:
		return storage[tile][0].type
func get_on(tile, property):
	if amount_on(tile) > 0:
		return storage[tile][0].get(property)

func max_stack_for(tile):
	if tiles.has(tile):
		if amount_on(tile) > 0:
			return storage[tile][0].max_stack
		return 1
	return 0

func get_tile_with_category(cat):
	for tile in storage:
		if get_on(tile, "category") == cat:
			return tile
func get_all_tiles_with_category(cat):
	var tiles = []
	for tile in storage:
		if get_on(tile, "category") == cat:
			tiles.push_back(tile)
	return tiles

func deposit(item, tile):
	if not can_put_on(item, tile):
		return false
	if not storage.has(tile):
		storage[tile] = []
	if item.stored_in:
		push_warning("storing item already stored")
		if item.stored_in == self:
			return true
		var stored_in = item.stored_in
		print(stored_in)
		push_error("trying to store item already stored elsewhere")
		var v = null
		(v as Array).clear()
	item.connect("deleted", self, "withdraw")
	storage[tile].append(item)
	item.stored_in = self
	emit_signal("amount_changed", item, tile, storage[tile].size())
	emit_signal("item_deposited", item, tile)
	return true

func withdraw(item):
	for tile in storage:
		if storage[tile].has(item):
			#print("withdrawing from ", tile)
			item.disconnect("deleted", self, "withdraw")
			storage[tile].erase(item)
			item.stored_in = null
			emit_signal("amount_changed", item, tile, storage[tile].size())
			return true

var first
var last
var w_first
var w_last
var w_size
func _draw():
	if first == null or last == null:
		first = tiles[0]
		last = tiles[-1]
		for tile in tiles:
			if tile.x < first.x or tile.y < first.y:
				first = tile
			if tile.x > last.x or tile.y > last.y:
				last = tile
		w_first = map.map_to_world(first)
		w_last = map.map_to_world(last)
		w_size = w_last - w_first + map.cell_size
		
		$Area2D/CollisionShape2D.shape.extents = w_size/2
		$Area2D.position = w_first+$Area2D/CollisionShape2D.shape.extents
	
	if selected:
		draw_rect(Rect2(w_first, w_size), Color(color.r, color.g, color.b, 0.5), true)
		draw_rect(Rect2(w_first, w_size), color, false, 3)
	elif highlighted:
		draw_rect(Rect2(w_first, w_size), color, false, 3)
	else:
		draw_rect(Rect2(w_first, w_size), color, false, 1)


func _on_Area2D_mouse_entered():
	highlighted = true
	update()

func _on_Area2D_mouse_exited():
	highlighted = false
	update()
