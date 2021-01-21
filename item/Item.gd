extends Node2D

signal deleted(item)

const is_item = true
export (String) var type
export (int) var max_stack = 1

var _id
var held
var stored_in # storage chunk node or null if not stored anywhere

var selected = false setget set_selected
func set_selected(s):
	selected = s
	$Selection.visible = s

func queue_free():
	emit_signal("deleted", self)
	.queue_free()

func _to_string():
	return type+":"+str(_id)

func withdraw():
	if stored_in: stored_in.withdraw(self)
	stored_in = null

var icon : Texture setget set_, get_icon
func get_icon():
	return $Sprite.texture

func set_(_a): pass
