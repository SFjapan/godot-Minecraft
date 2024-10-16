class_name Item
extends Resource
enum type{
	Food,
	Tool,
	Block,
}

@export var item_type:type
@export var item_scene:PackedScene
@export var item_icon:Texture2D
@export var item_name:String
@export var item_max_stack:int
