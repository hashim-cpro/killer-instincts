extends CanvasLayer

@onready var FPS_label = $Label

func _physics_process(_delta: float) -> void:
	FPS_label.text = "FPS: " + str(Engine.get_frames_per_second())
