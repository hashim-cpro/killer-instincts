extends Control

const displayOptions = [0, 3, 4]
const resolutionOptions = [[2560, 1440], [1920, 1080], [1366, 768], [1280, 720], [1920, 1200], [1680, 1050], [1440, 900], [1280, 800], [800, 600], [640, 480]]

func _on_display_options_button_item_selected(index: int) -> void:	
	$Window.set_mode = displayOptions[index]

func _on_resolution_option_button_item_selected(index: int) -> void:
	$Window.set_size(Vector2i(resolutionOptions[index][0], resolutionOptions[index][1]))
