extends Node

var items = {}

var items_by_category = {}

func _ready():
	for c in get_children():
		register_child(c)

func get_by_id(id):
	return items.get(id)
func get_by_category(cat):
	return items_by_category.get(cat, [])

func add_child(item_node, legible_unique_name=false):
	if register_child(item_node):
		.add_child(item_node, legible_unique_name)

func register_child(item_node):
	if not item_node.get("is_item"):
		push_error("tried to add item that is not an item "+ item_node.name)
		return false
	var id = _get_next_id()
	items[id] = item_node
	item_node._id = id
	item_node.connect("deleted", self, "on_delete")
	#print("adding item id ", id)
	
	var c = item_node.get("category")
	if c:
		if not items_by_category.has(c):
			items_by_category[c] = []
		items_by_category[c].append(item_node)
	return true

func on_delete(item):
	items.erase(item)
	var c = item.get("category")
	if c and items_by_category.has(c):
		items_by_category[c].erase(item)

func _get_next_id():
	for i in range(999999):
		if not items.has(i) or items[i] == null or not is_instance_valid(items[i]):
			return i
	push_error("Too many items")
