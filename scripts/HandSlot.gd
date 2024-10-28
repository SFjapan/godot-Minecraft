class_name HandSlot
extends TextureRect

@onready var item_slot:TextureRect = $TextureRect
@onready var parent = $".."
@onready var body:Player = $"../../.."
@onready var bg = preload("res://border.png")
@onready var border = preload("res://border_black.png") 
@onready var stack_label:Label = $Label
var index = 0
var stack:int = 0
var item:Item
func  _ready():
	item_slot.texture = null
	stack_label.text = " "
	item = null
	index = get_index()
	print(index)
	if body:
		body.change_hand_slot.connect(change_slot)
	else:
		print("non parent")	
	if index == 0:
		texture = border
		body.hand_slot = self	
	pass

func change_slot(index:int):
	if self.index == index:		
		print(index,self.index)	
		texture = border
		body.hand_slot = self
	else:
		texture = bg

func update_slot():
	if not item or stack < 1:
		item = null
		item_slot.texture = null
		stack = 0
		stack_label.text = " "	
	else:
		item_slot.texture = item.item_icon
		stack_label.text = str(stack)	
		
	for index in Inventory.inventory.size():
		if index == self.index:
			Inventory.inventory[index] = {
				"item":item,
				"count":stack
			}
			
#drag and drop

func _get_drag_data(at_position):
	# draging preview
	var preview = TextureRect.new()
	preview.texture = self.texture
	preview.expand_mode = 1
	preview.size = Vector2(50,50)
	
	var preview_child = TextureRect.new()
	preview_child.texture = item_slot.texture
	preview_child.expand_mode = 1
	preview_child.size = Vector2(40,40)
	preview_child.position = Vector2(5,5)
	
	var preview_label = Label.new()
	preview_label.text = str(stack)
	preview_label.size = Vector2(30,30)
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	preview_label.position = Vector2(15,25)
	
	preview.add_child(preview_child)
	preview.add_child(preview_label)
	var control = Control.new()
	control.add_child(preview)
	
	set_drag_preview(control)
	return self
	
func _can_drop_data(at_position, data):
	return data is TextureRect
	
func _drop_data(at_position, data):
	var inv = Inventory.inventory
	if data is Slot or data is HandSlot:
		if not data.item:
			return
		#同じアイテム	
		if data.item == self.item:
			if self.stack + data.stack > self.item.item_max_stack:
				data.stack = self.stack + data.stack -self.item.item_max_stack
				self.stack = self.item.item_max_stack
			else:
				self.stack += data.stack
				data.item = null	
				data.stack = 0			
			data.update_slot()
			self.update_slot()
				
		elif not self.item:
			#update slot
			self.item = data.item
			self.stack = data.stack
			self.update_slot()	
			#clear slot
			data.item = null
			data.stack = 0
			data.update_slot()

		inv[self.index]= {"item":self.item,"count":self.stack}
		inv[data.index]={"item":data.item,"count":data.stack}	
	print(data)
