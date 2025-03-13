extends Node

var settings = {
	"displayMode": DisplayServer.WINDOW_MODE_FULLSCREEN,
	"resolution": [1280, 720],
	"vsync": false,
	"showFPS": false,
	"fpsLimit": 60,
	"borderless": false,
	"brightness": 100,
	"masterVolume": 100,
	"sfxVolume": 100,
	"musicVolume": 100
}

const gameData = "user://savedata.bin"

func _ready() -> void:
	if (!FileAccess.file_exists(gameData)):
		var file = FileAccess.open(gameData, FileAccess.WRITE_READ)
		file.store_var(settings)
