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

@export var circle_radius = 30
@export var selection_radius = 60 # New: Radius for selection, slightly larger than circle_radius
@export var segment_count = 8 # Number of segments in the circle
@export var selected_segment = -1 # -1 means no segment is selected
@export var segment_colors : Array[Color] = [
	Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1),
	Color(1, 1, 0), Color(1, 0, 1), Color(0, 1, 1),
	Color(1, 0.5, 0), Color(0.5, 0, 1)
]
var draw_circle_active = false # Control variable for circle visibility

func _ready():
	set_process_input(true) # Enable input processing
	animated_sprite.animation_finished.connect(_on_animation_finished)
	var gun = get_node_or_null("../Gun")
	if gun:
		#print("Gun node found in player script!")
		#print("Attempting to connect to signal...")
		gun._if_body_entered.connect(_on_gun_picked_up)
		#print("Signal connection attempted!")
	#else:
		#print("Gun node NOT found in player script! Check node name and hierarchy.") # Debug print


func _physics_process(_delta: float) -> void: # Fixed UNUSED_PARAMETER warning
	#print("--- Physics Process Frame ---") # Frame marker

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * _delta
		#print("Applying Gravity: Velocity Y =", velocity.y) # Debug gravity
	#else:
		#print("Is on floor: True") # Debug is_on_floor

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		standing_collision.disabled = false
		crouching_collision.disabled = true
		#print("Jump Action! Velocity Y =", velocity.y) # Debug jump

	# Horizontal Movement
	var direction := Input.get_axis("left", "right")
	#print("Input Direction:", direction) # Debug input direction
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

	# Crouch (No debug prints needed here for now)
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

	# Check if landed (No debug prints needed here for now)
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

	# Attack (No debug prints needed here for now)
	if Input.is_action_just_pressed("attack"):
		is_throwing = true
		if has_gun:
			animated_sprite.play("shoot")
			shoot_bullet()
		else:
			animated_sprite.play("throw")
			hit_box_collision.disabled = false


	move_and_slide()
	#print("Velocity after move_and_slide: Velocity =", velocity) # Debug velocity after move_and_slide
	#print("Is on floor (after move_and_slide):", is_on_floor()) # Debug is_on_floor after move_and_slide
	#print("--------------------------") # Frame separator


func _on_animation_finished():
	if animated_sprite.animation == "throw" or animated_sprite.animation == "shoot": # Added "gun throw" here
		is_throwing = false
		hit_box_collision.disabled = true

func _on_gun_picked_up(body):
	if body == self: #
		#print("Signal Handler in Player Script: _on_gun_picked_up CALLED!")
		#print("Picked up a Gun! (from player script)")
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

func _draw():
	if draw_circle_active: # Only draw if right mouse button is held
		draw_circle(Vector2.ZERO, circle_radius, Color(1, 1, 1, 0.5)) # Base circle

		for i in range(segment_count):
			var angle_start = deg_to_rad(i * 360 / segment_count)
			var angle_end = deg_to_rad((i + 1) * 360 / segment_count)
			var color = segment_colors[i % segment_colors.size()] # Use segment_colors array
			var line_width = 10 # Default line width
			var segment_draw_radius = circle_radius # Default draw radius
			var segment_offset = Vector2.ZERO # Default offset

			if i == selected_segment:
				#color = Color(1, 0, 0) # Highlight selected segment in red
				line_width = 8 # Make selected segment thicker
				segment_draw_radius = circle_radius + 5 # Slightly larger radius
				var segment_angle_mid = deg_to_rad((i + 0.5) * 360 / segment_count) # Mid-angle of segment
				segment_offset = Vector2(cos(segment_angle_mid), sin(segment_angle_mid)) * 5 # Offset outwards

			draw_arc(segment_offset, segment_draw_radius, angle_start, angle_end, segment_count * 2, color, line_width)

func _input(event):
	if event.is_action_pressed("right_click"): # Right mouse button pressed
		draw_circle_active = true # Activate circle drawing
		#print("Right Click Pressed - Circle Active:", draw_circle_active)

	elif event.is_action_released("right_click"): # Right mouse button released
		draw_circle_active = false # Deactivate circle drawing
		#print("Right Click Released - Circle Active:", draw_circle_active)
		selected_segment = -1 # Reset selected segment

	if draw_circle_active and event is InputEventMouseMotion: # Detect mouse motion only when circle is active
		var mouse_pos = get_local_mouse_position() # Mouse position relative to the character
		var mouse_dist = mouse_pos.length() # Distance from center
		var angle_to_mouse_rad = mouse_pos.angle() # Angle from character to mouse in radians
		var angle_to_mouse_deg = rad_to_deg(angle_to_mouse_rad) # Angle in degrees

		# Normalize angle to 0-360 range
		if angle_to_mouse_deg < 0:
			angle_to_mouse_deg += 360.0

		#print("Mouse Angle (Degrees):", angle_to_mouse_deg, "Distance:", mouse_dist) # Debug print - Angle and Distance

		if mouse_dist > circle_radius and mouse_dist <= selection_radius: # Mouse outside circle_radius but inside selection_radius
			var segment_index = angle_to_mouse_deg / (360.0 / segment_count)
			selected_segment = int(segment_index) % segment_count # Calculate segment index
			#print("Mouse in Selection Range - Selected Segment:", selected_segment) # Debug print - Segment Index
		elif mouse_dist <= circle_radius: # Mouse inside circle_radius, deselect
			selected_segment = -1 # Deselect if mouse is inside the circle
			#print("Mouse INSIDE Circle - Selected Segment:", selected_segment) # Debug print
		else: # Mouse outside selection_radius, deselect as well (optional, for clarity)
			selected_segment = -1
			#print("Mouse OUTSIDE Selection Range - Selected Segment:", selected_segment)

	queue_redraw() # Request redraw to update circle visibility and segment highlighting
