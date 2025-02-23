extends Area2D

@onready var bar = $"../../CanvasLayer/Bar"

func _on_body_entered(_body: Node2D) -> void:
	print("+1 coin")
	bar.setCoinAmount(bar.getCoinAmount() + 1)
	queue_free()
