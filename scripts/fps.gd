extends Label
@onready var character_body_3d = $".."

func _process(delta):
	text = "FPS:" + str(Engine.get_frames_per_second())
	text += "\n" + str(character_body_3d.position.x) + "," + str(character_body_3d.position.y) + "," + str(character_body_3d.position.z)
