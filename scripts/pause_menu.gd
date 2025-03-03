extends Control

func _ready() -> void:
	visible = false

var _is_paused: bool = false:
	set = set_paused

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		self._is_paused = !_is_paused

func set_paused(value: bool) -> void:
	_is_paused = value
	visible = _is_paused
	get_tree().paused = _is_paused

func _on_resume_button_pressed() -> void:
	_is_paused = !_is_paused
	get_tree().paused = _is_paused

func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
