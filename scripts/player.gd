extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -250.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var standing_collision = $StandingCollisionShape2D
@onready var crouching_collision = $CrouchingCollisionShape2D
@onready var hit_box_collision = $HitBox/CollisionShape2D

var bullet_scene = preload("res://scenes/bullet.tscn")
var is_throwing = false 
var has_gun = false 

func _ready():
	animated_sprite.animation_finished.connect(_on_animation_finished)
	var gun = get_node_or_null("../Gun") 
	if gun:
		print("Gun node found in player script!") 
		print("Attempting to connect to signal...") 
		gun._if_body_entered.connect(_on_gun_picked_up) 
		print("Signal connection attempted!") 
	else:
		print("Gun node NOT found in player script! Check node name and hierarchy.") # Debug print


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		standing_collision.disabled = false
		crouching_collision.disabled = true

	# Horizontal Movement
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		if is_on_floor() and not is_throwing:
			if has_gun:
				animated_sprite.play("gun walk")
			else:
				animated_sprite.play("walk")
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and not is_throwing:
			if has_gun:
				animated_sprite.play("gun idle")
			else:
				animated_sprite.play("idle")

	# Crouch
	if Input.is_action_pressed("crouch"):
		if not is_throwing:
			if has_gun:
				animated_sprite.play("gun crouch") 
			else:
				# A missing animation
				animated_sprite.play("gun crouch") 
		standing_collision.disabled = true
		crouching_collision.disabled = false
	else:
		standing_collision.disabled = false
		crouching_collision.disabled = true

	# Check if landed
	if is_on_floor():
		if animated_sprite.animation in ["jump", "fall jump"] and not is_throwing:
			if has_gun:
				animated_sprite.play("gun idle")
			else:
				animated_sprite.play("idle")
	else:
		if velocity.y < 0 and not is_throwing:
			if has_gun:
				animated_sprite.play("gun jump")
			else:
				animated_sprite.play("jump")
		elif velocity.y > 0 and not is_throwing:
			if has_gun:
				animated_sprite.play("gun fall jump") 
			else:
				animated_sprite.play("fall jump")

	# Attack 
	if Input.is_action_just_pressed("attack"):
		is_throwing = true
		if has_gun:
			animated_sprite.play("shoot") 
			shoot_bullet()
		else:
			animated_sprite.play("throw")
			hit_box_collision.disabled = false


	move_and_slide()

func _on_animation_finished():
	if animated_sprite.animation == "throw" or animated_sprite.animation == "shoot": # Added "gun throw" here
		is_throwing = false 
		hit_box_collision.disabled = true

func _on_gun_picked_up(body):
	if body == self: #
		print("Signal Handler in Player Script: _on_gun_picked_up CALLED!") 
		print("Picked up a Gun! (from player script)")
		has_gun = true
		var gun = get_node_or_null("../Gun") 
		if gun:
			gun.queue_free() 

func shoot_bullet():
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.position = global_position
	var facing_direction = Vector2.LEFT if animated_sprite.flip_h  else Vector2.RIGHT
	bullet_instance.direction = facing_direction 
	get_parent().add_child(bullet_instance)
