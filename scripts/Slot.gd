class_name Slot
extends TextureRect

@onready var item_slot:TextureRect = $TextureRect
@export var item:Item
@onready var stack_label = $Label

var stack = 0
func _ready():
	set_item(preload("res://items/Grass/Grass.tres"),1)
func set_item(item:Item,count:int):
	if self.item:
		if self.item == item:
			stack += count
			
	else :
		self.item = item
		stack = count
		item_slot.texture = self.item.item_icon
		stack_label.text = str(stack)

func update_slot():
	if not item:
		item_slot.texture = null
		stack = 0
		stack_label.text = ""	
	else:
		item_slot.texture = item.item_icon
		stack_label.text = str(stack)		
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
	if data is Slot or data is HandSlot:
		if data.item == self.item and data.stack + self.stack < data.item.item_max_stack:
			self.stack += data.stack
			data.item = null
			
		elif not self.item:
			#update slot
			self.item = data.item
			self.stack = data.stack

			#clear slot
			data.item = null

	data.update_slot()
	self.update_slot()		
	print(data)

