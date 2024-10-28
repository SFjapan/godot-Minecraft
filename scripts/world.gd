extends Node3D

var noise = FastNoiseLite.new()
@onready var  grass:PackedScene = preload("res://items/Grass/Grass.tscn")
@onready var stone:PackedScene = preload("res://items/Stone/Stone.tscn")
var min_height = -10
# Called when the node enters the scene tree for the first time.
func _ready():
	noise.noise_type = FastNoiseLite.DISTANCE_EUCLIDEAN  # ノイズのタイプを設定
	noise.frequency = randf_range(0.01,0.08)  # 周波数を設定（スケールを調整）  
	noise.seed = randi()
	randomize()
	generate_chunk()
	hide_block()
	Engine.max_fps = 0
	
func generate_chunk():
	var chunk_count = 1
	var chunk_size = Vector3(16, 16, 16)
	var block_size = 1.0

	for count in chunk_count:
		var chunk_x = count % 2
		var chunk_z = int(count / 2)
		var chunk_offset = Vector3(chunk_x * chunk_size.x * block_size, 0, chunk_z * chunk_size.z * block_size)

		for x in range(chunk_size.x):
			for z in range(chunk_size.z):
				var height = int(noise.get_noise_2d(x, z) * 10.0 + 10.0)  #一マスの最大の高さ
				for y in range(min_height,height,1):
					var b = grass
					if y < 8:
						b = stone
					var block = create_block(Vector3(x * block_size, y * block_size, z * block_size) + chunk_offset,b)
					add_child(block)


func create_block(position: Vector3,block:PackedScene):
	var current_block = block.instantiate() as Block
	if not current_block.block_item:
		var item_path = "res://items/" + current_block.BlockName + "/" + current_block.BlockName + ".tres"
		current_block.block_item = ResourceLoader.load(item_path) as Item
	current_block.position = position
	return current_block
	
func hide_block():
	var blocks = get_tree().get_nodes_in_group("Block")
	for block in blocks:
		#周りにブロックがある場合MeshとOutlineを表示せず作る
		var adjacents = [
							Vector3(block.position.x-1,block.position.y,block.position.z),Vector3(block.position.x+1,block.position.y,block.position.z),
							Vector3(block.position.x,block.position.y-1,block.position.z),Vector3(block.position.x,block.position.y+1,block.position.z),
							Vector3(block.position.x,block.position.y,block.position.z-1),Vector3(block.position.x,block.position.y,block.position.z+1),
						]
		var count = 0;				
		for i in adjacents:
			var space = PhysicsServer3D.space_get_direct_state(get_world_3d().get_space())
			var parameters = PhysicsPointQueryParameters3D.new()
			parameters.position = i
			parameters.collide_with_areas = true
			parameters.collide_with_bodies = true
			parameters.collision_mask = 2
			var result = space.intersect_point(parameters)
			if result:
				count+=1
		if count >= 6:
			block.get_child(0).visible = false
			block.get_child(1).visible = false		
