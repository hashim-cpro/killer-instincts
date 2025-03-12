extends Node

const save_file = "user://savefile.save"

var game_data = {}

func _ready() -> void:
	loadData()

func loadData() -> void:
	if not FileAccess.file_exists(save_file):
		game_data = {
			"fullscreen": true,
			"vsync": false,
			"showFps": false,
			"maxFps": 0,
			"bloom": false,
			"brightness": 1,
			"masterVolume": -10,
			"musicVolume": -10,
			"sfxVolume": -10
		}
		saveData()
	else:
		var file = FileAccess.open(save_file, FileAccess.READ)
		game_data = file.get_var()
		file.close()

func saveData():
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	file.store_var(game_data)
	file.close()
