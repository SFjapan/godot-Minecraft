extends Node

var inventory :Array[Dictionary]
const slot_count = 50 
signal added_item
func _ready():
	inventory.resize(slot_count)
	for i in inventory.size():
		inventory[i] = {
			"item":null,
			"count":0
		}
func add_item(item:Item,count:int):
	if not item:
		print("non item")
	for i in inventory.size():
		if not inventory[i].item:
			inventory[i] = {
				"item" : item,
				"count" : count
			}
			added_item.emit()
			return
		elif inventory[i].item == item and inventory[i].count + count <= item.item_max_stack:
			inventory[i] = {
				"item":item,
				"count":inventory[i].count + count
			}
			added_item.emit()
			return
			  		
		
