extends CharacterBody3D
class_name Player
signal select_obj
signal change_hand_slot

const SPEED = 5.0
const JUMP_VELOCITY = 4.5


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera:Camera3D = $Camera3D
@export var sensitivity = 0.02
@onready var raycast:RayCast3D =  $Camera3D/RayCast3D

#hand dig power 
@export var power = 1

#quick slot
@onready var hand_slots_parent = $HandSlots
var hand_slots
#inventory
@onready var inv = $inv
@onready var inv_slots_parent = $inv/GridContainer
var inventory = Inventory.inventory 
var inv_slots
var open_inv:bool = false

var collider		#ray hit collider
var hand_slot:HandSlot		#hand item
		

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
	inv_slots = inv_slots_parent.get_children()
	hand_slots = hand_slots_parent.get_child(0).get_children()
	Inventory.added_item.connect(update_slot)
	inv.visible = false

func _physics_process(delta):
	
	#show hide Inventory
	if Input.is_action_just_pressed("Inv"):
		open_inv = !open_inv
		inv.visible = open_inv
		if inv.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	#gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
				
	if open_inv:
		return		  	
	#jump
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY					 
	#ray cast camera			
	if raycast.is_colliding():
		collider = raycast.get_collider()
		if collider is Block:
			collider = collider as Block
			select_obj.emit(collider)
			# dig forward block
			if Input.is_action_pressed("left_click"):
				collider.dig(power)
			#place block	
			elif Input.is_action_pressed("right_click"):
				if not hand_slot or not hand_slot.item :
					return
				match hand_slot.item.item_type:
					Item.type.Block:
						set_block(hand_slot.item.item_scene,collider.position + raycast.get_collision_normal())
					_:
						return	
			else:	
				collider.Endurance = collider.MAX_Endurance	
	else:
		select_obj.emit(null)

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			var index = 0
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				index = hand_slot.index + 1
				if index > hand_slots.size():
					index = 0
				change_hand_slot.emit(index)
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				index = hand_slot.index - 1
				if index < 0:
					index = hand_slots.size()-1
				change_hand_slot.emit(index)
		
	if event is InputEventMouseMotion and not open_inv:
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-90),deg_to_rad(90))
		rotate_y(-event.relative.x * sensitivity)

func set_block(block:PackedScene,position:Vector3):
	# can place ?
	var space = PhysicsServer3D.space_get_direct_state(get_world_3d().get_space())
	var parameters = PhysicsPointQueryParameters3D.new()
	parameters.position = position
	parameters.collide_with_areas = true
	parameters.collide_with_bodies = true
	parameters.collision_mask = 1
	var result = space.intersect_point(parameters)
	if result:
		return
	parameters.position = position + Vector3(0,1,0)
	result = space.intersect_point(parameters)
	if result:
		return
	# if new block pos is filled return
	print(parameters.position)
	
	var instance = block.instantiate() as Block
	instance.position =position
	var item_path = "res://items/" + instance.BlockName + "/" + instance.BlockName + ".tres"
	instance.block_item = ResourceLoader.load(item_path) as Item
	get_parent().add_child(instance)
	hand_slot.stack -= 1
	hand_slot.update_slot()

func update_slot():
	#ハンドスロット優先
	for i in inventory.size():
		var placed:bool = false
		if i < 11:
			for h_slot:HandSlot in hand_slots:
				if not h_slot.item:
					h_slot.item = inventory[i].item as Item
					h_slot.stack = inventory[i].count as int	
					h_slot.update_slot()
					placed = true
					break	
				elif h_slot.item and h_slot.index == i:
					h_slot.stack = inventory[i].count as int
					h_slot.update_slot()
					placed = true
					break
		elif not placed and i >= 11:		
			for i_slot:Slot in inv_slots:
				if not i_slot.item:
					i_slot.item = inventory[i].item as Item
					i_slot.stack = inventory[i].count as int
					i_slot.update_slot()	
					break
				elif i_slot.item and i_slot.index == i:
					i_slot.stack = inventory[i].count as int
					i_slot.update_slot()
					break					
	pass
