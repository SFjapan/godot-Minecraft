extends Node

var inventory :Array[Dictionary] 
func _ready():
	inventory.resize(40)
	
func add_item(item:Item,count:int):
	if not item:
		print("non item")
	print(inventory)	
	for i in inventory.size():
		if not inventory[i]:
			inventory[i] = {
				"item" = item,
				"count" = count
			}
			return
		elif inventory[i].item == item and inventory[i].count + count <= item.item_max_stack:
			inventory[i] = {
				"item":item,
				"count":inventory[i].count + count
			}
			return
			  		
		
