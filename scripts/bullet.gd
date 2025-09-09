extends Area2D

@export var bullet_speed: float = 200.0 # bullet's speed
@export var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	add_to_group("bullets")
	# Automatically delete bullet when it leaves the screen
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	# Connect collision signal
	#area_entered.connect(_on_area_entered)
	#body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:

	position += direction * bullet_speed * delta


#==============NOT WORKING================
#func _on_area_entered(area: Area2D) -> void:
	## Currently trying to destroy the bullet everytime it enters a area 2d
	#if area.name == "Spline enemy":
		#queue_free()  # Destroy bullet, this won't work
#
#func _on_body_entered(body: Node) -> void:
	## Handle collisions with walls/terrain (assuming they're PhysicsBody2D)
	#if body.is_in_group("environment"):
		#queue_free()  # Destroy bullet when hitting walls
