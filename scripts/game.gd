extends Node2D

const save_path = "user://gamedata.save"

func _ready() -> void:
	if FileAccess.file_exists(save_path):
		print("Game data found")
		#var file = FileAccess.open(save_path, FileAccess.READ)
		#file.get_var()

func _process(delta: float) -> void:
	pass
