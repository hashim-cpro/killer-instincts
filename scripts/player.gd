extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -250.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var standing_collision = $StandingCollisionShape2D
@onready var crouching_collision = $CrouchingCollisionShape2D
@onready var hit_box_collision = $HitBox/CollisionShape2D
@onready var pickup_countdown_label: Label = $Label
@onready var jump_boost_countdown_timer: Timer = $"../jump boost/Timer"
@onready var speed_boost_countdown_timer: Timer = $"../speed boost/Timer"


var bullet_scene = preload("res://scenes/bullet.tscn")
var is_throwing = false
var has_gun = false
var has_jump_boost = false
var jump_count = 0
var has_speed_boost = false
var jump_boost_duration = 15.0
var speed_boost_duration = 10.0
var remaining_jump_boost_time: float = 0.0
var remaining_speed_boost_time: float = 0.0

@export var circle_radius = 30
@export var selection_radius = 500
@export var segment_count = 8
@export var selected_segment = -1
@export var segment_colors : Array[Color] = [
	Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1),
	Color(1, 1, 0), Color(1, 0, 1), Color(0, 1, 1),
	Color(1, 0.5, 0), Color(0.5, 0, 1)
]
var draw_circle_active = false
# No need for draw_circle_origin, since we're not drawing at the mouse position

func _ready():
	set_process_input(true)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	var gun = get_node_or_null("../Gun")
	if gun:
		gun._if_body_entered.connect(_on_gun_picked_up)
	var jumpboost = get_node_or_null("../jump boost")
	if jumpboost:
		jump_boost_countdown_timer.timeout.connect(_on_jump_boost_pickup_timeout)
		jumpboost._if_body_entered.connect(_on_jump_boost_pickup)

	var speedboost = get_node_or_null("../speed boost")
	if speedboost:
		speed_boost_countdown_timer.timeout.connect(_on_speed_boost_pickup_timeout)
		speedboost._if_body_entered.connect(_on_speed_boost_pickup)
		
func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * _delta
	elif has_jump_boost:
		jump_count = 0
	# for double jumps
	if Input.is_action_just_pressed("jump") and (has_jump_boost and jump_count < 2):
		velocity.y = JUMP_VELOCITY
		standing_collision.disabled = false
		crouching_collision.disabled = true
		jump_count += 1
	# for single jumps
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		standing_collision.disabled = false
		crouching_collision.disabled = true
	# now need to work out on adding new power ups and stuff because i don't know when hackatime is going to refresh also need to work on some other stuff like i don't know maybe 
	var direction := Input.get_axis("left", "right")
	if direction:
		if has_speed_boost:
			velocity.x = direction * SPEED * 2
		else:
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

	if Input.is_action_pressed("crouch"):
		if not is_throwing:
			if has_gun:
				animated_sprite.play("gun crouch")
			else:
				animated_sprite.play("gun crouch")
		standing_collision.disabled = true
		crouching_collision.disabled = false
	else:
		standing_collision.disabled = false
		crouching_collision.disabled = true

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

	if Input.is_action_just_pressed("attack"):
		is_throwing = true
		if has_gun:
			animated_sprite.play("shoot")
			shoot_bullet()
		else:
			animated_sprite.play("throw")
			hit_box_collision.disabled = false
	
	if jump_boost_countdown_timer and !jump_boost_countdown_timer.is_stopped():
		remaining_jump_boost_time = jump_boost_countdown_timer.time_left
		$Label.text = "Jump Boost " + str(remaining_jump_boost_time)
	if speed_boost_countdown_timer and !speed_boost_countdown_timer.is_stopped():
		remaining_speed_boost_time = speed_boost_countdown_timer.time_left
		$Label.text = "Speed Boost " + str(remaining_speed_boost_time)
	
	move_and_slide()

func _on_animation_finished():
	if animated_sprite.animation == "throw" or animated_sprite.animation == "shoot":
		is_throwing = false
		hit_box_collision.disabled = true

func _on_gun_picked_up(body):
	if body == self:
		has_gun = true
		var gun = get_node_or_null("../Gun")
		if gun:
			gun.queue_free()

func _on_jump_boost_pickup(body):
	if body == self:
		has_jump_boost = true
		remaining_jump_boost_time = jump_boost_duration
		jump_boost_countdown_timer.wait_time = jump_boost_duration
		jump_boost_countdown_timer.one_shot = true
		jump_boost_countdown_timer.start()
		
func _on_jump_boost_pickup_timeout():
	has_jump_boost = false
	$Label.text = "" 
	_remove_pickup("../jump boost")

func _on_speed_boost_pickup(body):
	if body == self:
		has_speed_boost = true
		remaining_speed_boost_time = speed_boost_duration
		speed_boost_countdown_timer.wait_time = speed_boost_duration
		speed_boost_countdown_timer.one_shot = true
		speed_boost_countdown_timer.start()
		
func _on_speed_boost_pickup_timeout():
	has_speed_boost = false
	$Label.text = "" 
	_remove_pickup("../speed boost")

func _remove_pickup(body: String):
	var body_to_be_removed = get_node_or_null(body)
	if body_to_be_removed:
		body_to_be_removed.queue_free()

func shoot_bullet():
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.position = global_position
	var facing_direction = Vector2.LEFT if animated_sprite.flip_h else Vector2.RIGHT
	bullet_instance.direction = facing_direction
	get_parent().add_child(bullet_instance)

func _draw():
	if draw_circle_active:
		# Draw the circle at the player's local origin (Vector2.ZERO)
		draw_circle(Vector2.ZERO, circle_radius, Color(1, 1, 1, 0.5))

		for i in range(segment_count):
			var angle_start = deg_to_rad(i * 360 / segment_count)
			var angle_end = deg_to_rad((i + 1) * 360 / segment_count)
			var color = segment_colors[i % segment_colors.size()]
			var line_width = 10
			var segment_draw_radius = circle_radius
			var segment_offset = Vector2.ZERO

			if i == selected_segment:
				line_width = 8
				segment_draw_radius = circle_radius + 5
				var segment_angle_mid = deg_to_rad((i + 0.5) * 360 / segment_count)
				segment_offset = Vector2(cos(segment_angle_mid), sin(segment_angle_mid)) * 5

			# Draw the arc relative to the player's position (Vector2.ZERO)
			draw_arc(segment_offset, segment_draw_radius, angle_start, angle_end, segment_count * 2, color, line_width)

func _input(event):
	if event.is_action_pressed("right_click"):
		draw_circle_active = true
	elif event.is_action_released("right_click"):
		draw_circle_active = false
		selected_segment = -1

	if draw_circle_active and event is InputEventMouseMotion:
		# Calculate the vector from the player's GLOBAL position to the mouse's GLOBAL position
		var mouse_pos_relative_to_player = get_global_mouse_position() - global_position
		var mouse_dist = mouse_pos_relative_to_player.length()
		var angle_to_mouse_rad = mouse_pos_relative_to_player.angle()
		var angle_to_mouse_deg = rad_to_deg(angle_to_mouse_rad)

		if angle_to_mouse_deg < 0:
			angle_to_mouse_deg += 360.0

		# Now, check if the mouse is within the selection_radius centered on the player
		if mouse_dist > circle_radius and mouse_dist <= selection_radius:
			var segment_index = angle_to_mouse_deg / (360.0 / segment_count)
			selected_segment = int(segment_index) % segment_count
		else:
			selected_segment = -1

	queue_redraw()
