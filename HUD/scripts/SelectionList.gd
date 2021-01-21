extends TabContainer

onready var selector = get_node("/root/Game/Selector")

onready var ant_list = $AntList
onready var item_list = $ItemList
onready var tile_list = $TileList

var selected_chunk

func _ready():
	var _a = selector.connect("selection_changed", self, "on_selection_changed")
	_a = selector.connect("mode_changed", self, "on_selection_mode_changed")

func on_selection_mode_changed(mode):
	match mode:
		selector.ModeKind.ANTS:
			current_tab = 0
			on_selection_changed(mode, [])
		selector.ModeKind.ITEMS:
			current_tab = 1
			on_selection_changed(mode, [])
		selector.ModeKind.TILES:
			current_tab = 2
			on_selection_changed(mode, [])

func on_selection_changed(mode, selected):
	if selected_chunk:
		selected_chunk.selected = false
		selected_chunk.disconnect("amount_changed", self, "on_amount_change")
		selected_chunk = null
	match mode:
		selector.ModeKind.ANTS:
			ant_list.show_info(selected)
		selector.ModeKind.ITEMS:
			item_list.show_info(selected)
		selector.ModeKind.TILES:
			tile_list.show_info(selected)


