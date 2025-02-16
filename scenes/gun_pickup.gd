#extends Area2D
#
#func _on_body_entered(body: Node2D) -> void:
	#print("Picked up a Gun!")
	#queue_free()

extends Area2D

signal _if_body_entered(body) # Define a custom signal

func _on_body_entered(body: Node2D) -> void:
	print("Player enetered gun area, removing gun...")
	emit_signal("_if_body_entered", body) # Emit the signal when the player enters
	queue_free() # The gun will be removed from the player script now
