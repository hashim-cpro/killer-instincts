extends Control

const displayOptions = [DisplayServer.WINDOW_MODE_WINDOWED, DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
const resolutionOptions = [[2560, 1440], [1920, 1080], [1366, 768], [1280, 720], [1920, 1200], [1680, 1050], [1440, 900], [1280, 800], [800, 600], [640, 480]]
const vsyncOptions = [DisplayServer.VSYNC_DISABLED, DisplayServer.VSYNC_ENABLED, DisplayServer.VSYNC_ADAPTIVE, DisplayServer.VSYNC_MAILBOX]

func _on_display_options_button_item_selected(index: int) -> void:	
	DisplayServer.window_set_mode(displayOptions[index])

func _on_resolution_option_button_item_selected(index: int) -> void:
	DisplayServer.window_set_size(Vector2i(resolutionOptions[index][0], resolutionOptions[index][1]))

func _on_v_sync_button_item_selected(index: int) -> void:
	DisplayServer.window_set_vsync_mode(vsyncOptions[index])

func _on_display_fps_button_toggled(toggled_on: bool) -> void:
	pass

func _on_borderless_button_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, toggled_on)
