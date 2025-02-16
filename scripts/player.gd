extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -250.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var standing_collision = $StandingCollisionShape2D
@onready var crouching_collision = $CrouchingCollisionShape2D
@onready var hit_box_collision = $HitBox/CollisionShape2D

var is_throwing = false # Tracks if the throw animation is active
var has_gun = false # Tracks if the player has picked up the gun

func _ready():
	animated_sprite.animation_finished.connect(_on_animation_finished)
	# Connect to the gun's signal (assuming the gun is a child in the scene)
	var gun = get_node_or_null("../Gun") # Replace "Gun" with the actual name of your gun node
	if gun:
		print("Gun node found in player script!") # Debug print
		print("Attempting to connect to signal...") # Debug print
		gun._if_body_entered.connect(_on_gun_picked_up) # Corrected signal name here
		print("Signal connection attempted!") # Debug print
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
				animated_sprite.play("gun walk") # Gun walk animation
			else:
				animated_sprite.play("walk")
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and not is_throwing:
			if has_gun:
				animated_sprite.play("gun idle") # Gun idle animation
			else:
				animated_sprite.play("idle")

	# Crouch
	if Input.is_action_pressed("crouch"):
		if not is_throwing:
			if has_gun:
				animated_sprite.play("gun crouch") # Gun crouch animation (you might need to create this)
			else:
				animated_sprite.play("gun crouch") # Using "gun crouch" animation even without gun for crouching. You can change this to a normal "crouch" if you have one.
		standing_collision.disabled = true
		crouching_collision.disabled = false
	else:
		standing_collision.disabled = false
		crouching_collision.disabled = true

	# Check if landed
	if is_on_floor():
		if animated_sprite.animation in ["jump", "fall jump"] and not is_throwing:
			if has_gun:
				animated_sprite.play("gun idle") # Gun idle after landing
			else:
				animated_sprite.play("idle")
	else:
		if velocity.y < 0 and not is_throwing:
			if has_gun:
				animated_sprite.play("gun jump") # Gun jump animation
			else:
				animated_sprite.play("jump")
		elif velocity.y > 0 and not is_throwing:
			if has_gun:
				animated_sprite.play("gun fall jump") # Gun fall jump animation
			else:
				animated_sprite.play("fall jump")

	# Attack (Throw with Gun - you might want to change this to shooting)
	if Input.is_action_just_pressed("attack"):
		is_throwing = true
		if has_gun:
			animated_sprite.play("shoot") # Gun throw animation (or gun shoot animation)
		else:
			animated_sprite.play("throw")
		hit_box_collision.disabled = false


	move_and_slide()

func _on_animation_finished():
	if animated_sprite.animation == "throw" or animated_sprite.animation == "shoot": # Added "gun throw" here
		is_throwing = false # Reset flag when throw animation ends
		hit_box_collision.disabled = true

func _on_gun_picked_up(body):
	if body == self: # Check if the player is the body that entered the gun area
		print("Signal Handler in Player Script: _on_gun_picked_up CALLED!") # Debug print
		print("Picked up a Gun! (from player script)")
		has_gun = true
		# Optionally, you can hide the gun sprite here from the player scene if it's still visible after pickup
		var gun = get_node_or_null("../Gun") # Replace "Gun" with the actual name of your gun node
		if gun:
			gun.queue_free() # Destroy the gun node after pickup from scene tree
