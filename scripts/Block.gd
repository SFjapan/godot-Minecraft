extends StaticBody3D
class_name Block

@export var BlockName:String
@export var MAX_Endurance:float 
@export var Endurance:float 
@onready var mesh:GeometryInstance3D = $GrassBlock
@onready var outline = $outline
@export var block_item:Item
var selected:bool = false


func _ready():
	Endurance = MAX_Endurance
	get_tree().get_first_node_in_group("Player").select_obj.connect(set_outline)

func _process(delta):
	outline.visible = selected
	if not selected:
		Endurance = MAX_Endurance
func set_outline(object):
	selected =  self == object

func dig(power:float):
	Endurance -= power
	if Endurance < 0:
		var adjacents = [
							Vector3(position.x-1,position.y,position.z),Vector3(position.x+1,position.y,position.z),
							Vector3(position.x,position.y-1,position.z),Vector3(position.x,position.y+1,position.z),
							Vector3(position.x,position.y,position.z-1),Vector3(position.x,position.y,position.z+1),
						]
		var count = 0		
		for i in adjacents:
			var space = PhysicsServer3D.space_get_direct_state(get_world_3d().get_space())
			var parameters = PhysicsPointQueryParameters3D.new()
			parameters.position = i
			parameters.collide_with_areas = true
			parameters.collide_with_bodies = true
			parameters.collision_mask = 2
			var result = space.intersect_point(parameters)
			if result:
				for col in result:
					if col.collider is StaticBody3D:
						col.collider.get_child(0).visible = true
						col.collider.get_child(1).visible = true
						
		Inventory.add_item(block_item,1)				
		queue_free()
