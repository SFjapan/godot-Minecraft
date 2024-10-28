extends Label
@onready var character_body_3d = $".."

func _process(delta):
	text = "FPS:" + str(Engine.get_frames_per_second())
	text += "\nx:" + str(character_body_3d.position.x) + "\ny:" + str(character_body_3d.position.y) + "\nz:" + str(character_body_3d.position.z)
