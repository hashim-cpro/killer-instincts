extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -250.0

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		animated_sprite.play("jump")
		velocity.y = JUMP_VELOCITY
		$StandingCollisionShape2D.disabled = false
		$CrouchingCollisionShape2D.disabled = true
	
	if Input.is_action_just_released("jump"):
		animated_sprite.play("idle")
	# Horizontal Movement
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	
	# Crouch
	if Input.is_action_pressed("crouch"):
		animated_sprite.play("gun crouch")
		$StandingCollisionShape2D.disabled = true
		$CrouchingCollisionShape2D.disabled = false
	else:
		$StandingCollisionShape2D.disabled = false
		$CrouchingCollisionShape2D.disabled = true
	
	# Attack
	#if Input.is_action_just_pressed(""):
		#animated_sprite.play("attack")
		#perform_attack()
	
	move_and_slide()

#func perform_attack() -> void:
	#$AttackHitbox.disabled = false
	#await(get_tree().create_timer(0.2), "timeout")
	#$AttackHitbox.disabled = true
