class_name Slot
extends TextureRect

@onready var item_slot:TextureRect = $TextureRect
@onready var parent = $".."
@onready var body = $"../../.."
@onready var bg = preload("res://border.png")
@onready var border = preload("res://border_black.png") 
@export var item:Item
func  _ready():
	if item:
		item_slot.texture = item.item_icon
	if body:
		print("ashd")
		body.change_hand_slot.connect(change_slot)
	else:
		print("non parent")	
	if parent.get_child(0) == self:
		texture = border
		body.hand_item = item	
	pass

func change_slot(index:int):
	print(index)
	if parent.get_child(index) == self:
		texture = border
		body.hand_item = item
	else:
		texture = bg
