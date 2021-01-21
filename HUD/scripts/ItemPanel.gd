extends Control

onready var description_node = $Text/Label
onready var icon_node = $Icon/PanelContainer/Sprite
onready var amount_node = $Amount/Label

var description : String setget set_description
func set_description(desc):
	description = desc
	description_node.text = desc

var icon : Texture setget set_icon
func set_icon(texture):
	icon = texture
	icon_node.texture = texture

var amount : int setget set_amount
func set_amount(new_amount):
	amount = new_amount
	amount_node.text = "X %d"%amount
