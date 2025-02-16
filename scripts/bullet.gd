extends Area2D

# Configuration
@export var bullet_speed: float = 600.0
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Automatically delete bullet when it leaves the screen
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	# Connect collision signal
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move bullet in specified direction
	position += direction * bullet_speed * delta

func _on_area_entered(area: Area2D) -> void:
	# Handle collisions with enemies (assuming enemies are in 'enemy' group)
	if area.is_in_group("enemy"):
		area.get_parent().queue_free()  # Destroy enemy
		queue_free()  # Destroy bullet

func _on_body_entered(body: Node) -> void:
	# Handle collisions with walls/terrain (assuming they're PhysicsBody2D)
	if body.is_in_group("environment"):
		queue_free()  # Destroy bullet when hitting walls
