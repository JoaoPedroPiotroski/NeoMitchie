extends CharacterBody2D


const HIGH_SLOPE_ANGLE = 0.78
const MEDIUM_SLOPE_ANGLE = 0.46
const LOW_SLOPE_ANGLE = 0.24
const STAIRSTEP_CD = 0.1

# Movement
var max_speed = (170 / 4) * 2
var base_max_speed = (170 / 4) * 2
var air_h_accel = 0.15
var floor_h_accel = 0.3
var fall_speed = 500
var base_jump_velocity = 250
var jump_velocity = 200
var jump_h_boost = 2
var base_gravity = 500
var gravity = base_gravity
var floor_friction = 0.2
var air_friction = 0.8

var normal
var angle

# Clocks
var jump_rq = -1
var jump_time = 0
var slide_cd = -1
var stairs_cd = -1

# Flags
var is_jumping = false
var is_sliding = false

var curr_anim = "idle"

@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var stairs_l_down = $Detectors/StairsLDown
@onready var stairs_r_down = $Detectors/StairsRDown
@onready var stairs_l_up = $Detectors/StairsLUp
@onready var stairs_l_mid = $Detectors/StairsLMid
@onready var stairs_r_up = $Detectors/StairsRUp
@onready var stairs_r_mid = $Detectors/StairsRMid

func _draw():
	return
	draw_line(Vector2.ZERO, velocity.rotated(normal.angle()), Color.BLUE, 5)
	draw_line(Vector2.ZERO, velocity, Color.LIGHT_BLUE, 5)
	draw_line(Vector2.ZERO, normal * 50, Color.SEASHELL, 5)
	

func _physics_process(delta):
	queue_redraw()
	var foo = Vector2.UP.angle()
	print(foo)
	if get_floor_angle() < 1:
		angle = get_floor_angle()
	normal = get_floor_normal()
	
	# clocks
	stairs_cd -= delta
	slide_cd -= delta
	jump_rq -= delta
	jump_time += delta
	
	# input
	var h_dir = Input.get_axis("left", "right")
	if Input.is_action_just_pressed("sprint"):
		max_speed = base_max_speed * 2
	if Input.is_action_just_released("sprint"):
		max_speed = base_max_speed
	if Input.is_action_pressed("jump"):
		gravity = base_gravity / 2.0
	else:
		gravity = base_gravity
	if Input.is_action_just_pressed("jump"):
		jump_time = 0
		jump_rq = 0.2
	if abs(get_floor_angle()) > LOW_SLOPE_ANGLE and Input.is_action_pressed("down") and is_on_floor():
		is_sliding = true
		slide_cd = 0.2
	if slide_cd < 0:
		is_sliding = false
		
	# walk
	if abs(h_dir) < 0.2 and is_on_floor():
		var friction_mult = 1
		if is_sliding:
			friction_mult = 0.1
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, (max_speed / floor_friction * friction_mult) * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, (max_speed / air_friction * friction_mult) * delta)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, h_dir * max_speed, (max_speed / floor_h_accel) * delta)
		else:
			velocity.x = move_toward(velocity.x, h_dir * max_speed, (max_speed / air_h_accel) * delta)
			
	# gravity
	velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)
		
	# jump
	if jump_rq > 0:
		if is_on_floor():
			jump_rq = -1
			is_jumping = true
			floor_snap_length = 0
			velocity.y = - jump_velocity
			#velocity = velocity.rotated(normal.angle())
			if h_dir != 0:
				velocity.x = velocity.x * jump_h_boost
	
	
	move_and_slide()
	
	# slope slide
	var slope_dir = 1 if get_floor_normal().x > 0 else -1
	if is_sliding:
		if angle > HIGH_SLOPE_ANGLE:
			velocity.y += 24 * 4 * delta * 100
			velocity.x += 30 * 1.5 * slope_dir * delta * 100
		elif angle > MEDIUM_SLOPE_ANGLE:
			velocity.y += 24 * 2 * delta * 100
			velocity.x += 30 * 1 * slope_dir * delta * 100
		elif angle > LOW_SLOPE_ANGLE:
			velocity.y += 24 * 0.9 * delta * 100
			velocity.x += 30 * 0.6 * slope_dir * delta * 100
			
	# floor snap
	if not is_jumping and not is_sliding:
		apply_floor_snap()
		floor_stop_on_slope = true
		floor_snap_length = 10
	if is_jumping or is_sliding:
		floor_snap_length = 0
		if is_sliding and not is_jumping:
			floor_stop_on_slope = false
		is_jumping = not is_on_floor()
		
	# animation
	
	if h_dir != 0:
		sprite.flip_h = h_dir > 0
		if abs(velocity.x) > base_max_speed:
			var transfer_time = curr_anim == "walk"
			var current_anim_time = animation.get_current_animation_position()
			curr_anim = "sprint"
			if transfer_time:
				animation.seek(current_anim_time, false)
		else:
			var transfer_time = curr_anim == "sprint"
			var current_anim_time = animation.get_current_animation_position()
			curr_anim = "walk"
			if transfer_time:
				animation.seek(current_anim_time, false)
	else:
		curr_anim = "idle"
	if animation.current_animation != curr_anim:
		animation.play(curr_anim)
	
