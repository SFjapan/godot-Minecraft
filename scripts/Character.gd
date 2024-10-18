extends CharacterBody3D

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
var hand_item:Item		#hand item
var hand_slot_index = 0		

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
	inv_slots = inv_slots_parent.get_children()
	hand_slots = hand_slots_parent.get_child(0).get_children()
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
			elif Input.is_action_just_pressed("right_click"):
				if not hand_item:
					return
				match hand_item.item_type:
					Item.type.Block:
						set_block(hand_item.item_scene,collider.position + raycast.get_collision_normal(),hand_slot_index)
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
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				hand_slot_index += 1
				print(hand_slot_index > hand_slots.size())
				if hand_slot_index > hand_slots.size():
					hand_slot_index = 0
				change_hand_slot.emit(hand_slot_index)
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				hand_slot_index -= 1
				print(hand_slot_index)
				if hand_slot_index < 0:
					hand_slot_index = hand_slots.size()-1
				change_hand_slot.emit(hand_slot_index)
		
	if event is InputEventMouseMotion and not open_inv:
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-90),deg_to_rad(90))
		rotate_y(-event.relative.x * sensitivity)

func set_block(block:PackedScene,position:Vector3,slot_index:int):
	# can place ?
	var space = PhysicsServer3D.space_get_direct_state(get_world_3d().get_space())
	var parameters = PhysicsPointQueryParameters3D.new()
	parameters.position = position
	parameters.collide_with_areas = true
	parameters.collide_with_bodies = true
	parameters.collision_mask = 1
	var result = space.intersect_point(parameters)
	# if new block pos is filled return
	if result:
		return
	var instance = block.instantiate() as StaticBody3D
	instance.position = position
	get_parent().add_child(instance)
	
	var slot = hand_slots_parent.get_child(0).get_child(slot_index)
	slot.stack -= 1
	slot.update_slot()


