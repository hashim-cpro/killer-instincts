extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -250.0

@onready var animated_sprite = $AnimatedSprite2D

var is_throwing = false  # Tracks if the throw animation is active

func _ready():
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$StandingCollisionShape2D.disabled = false
		$CrouchingCollisionShape2D.disabled = true
	
	# Horizontal Movement
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		if is_on_floor() and not is_throwing:
			animated_sprite.play("walk")
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and not is_throwing:
			animated_sprite.play("idle")
		
	# Crouch
	if Input.is_action_pressed("crouch"):
		if not is_throwing:
			animated_sprite.play("gun crouch")
		$StandingCollisionShape2D.disabled = true
		$CrouchingCollisionShape2D.disabled = false
	else:
		$StandingCollisionShape2D.disabled = false
		$CrouchingCollisionShape2D.disabled = true
	
	# Check if landed
	if is_on_floor():
		if animated_sprite.animation in ["jump", "fall jump"] and not is_throwing:
			animated_sprite.play("idle")
	else:
		if velocity.y < 0 and not is_throwing:
			animated_sprite.play("jump")
		elif velocity.y > 0 and not is_throwing:
			animated_sprite.play("fall jump")
	
	# Attack
	if Input.is_action_just_pressed("attack"):
		is_throwing = true
		animated_sprite.play("throw")
		$HitBox/CollisionShape2D.disabled = false
		
	
	move_and_slide()

func _on_animation_finished():
	if animated_sprite.animation == "throw":
		is_throwing = false  # Reset flag when throw animation ends
