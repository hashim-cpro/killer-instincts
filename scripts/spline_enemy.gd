extends Area2D

@onready var timer: Timer = $Timer

func _ready():
	# REMOVE manual body_entered connection (already connected via editor)
	# Only keep this connection:
	$HurtBox.area_entered.connect(_on_hurt_box_area_entered)

func _on_body_entered(_body: Node2D) -> void:
	print("==========You died!=============")
	timer.start()
	

func _on_hurt_box_area_entered(area: Area2D) -> void:
	# Check if colliding area is named "HitBox"
	if area.name == "HitBox" || area.is_in_group("bullets"):
		queue_free()
		print("Enemy died!")
		if area.is_in_group("bullets"):
			area.queue_free()

func _on_timer_timeout() -> void:
	print("========Game Restarted==========")
	get_tree().reload_current_scene()
	
# =========Movement Logic===============
const speed = 60

var direction = 1

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D

func _process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
		
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
		

	position.x += direction * speed * delta
