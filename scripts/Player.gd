extends CharacterBody2D

const STEEP_SLOPE_ANGLE = 0.75
const STEEP_UP_SPEED = 0.85
const STEEP_DOWN_SPEED = 1.35
const MEDIUM_SLOPE_ANGLE = 0.44
const MEDIUM_UP_SPEED = 0.9
const MEDIUM_DOWN_SPEED = 1.25
const SHALLOW_SLOPE_ANGLE = 0.23
const SHALLOW_UP_SPEED = 0.95
const SHALLOW_DOWN_SPEED = 1.2
const FLAT_SLOPE = 0
const STAIRSTEP_CD = 0.1

# Movement
var current_slope = FLAT_SLOPE
var slope_dir = 1
var max_speed : float = 100
var base_max_speed : float = 100
var sprint_mult : float = 1.5
var slope_mult : float = 1.0
var air_h_accel : float = 0.15
var floor_h_accel : float = 0.3
var fall_speed : float = 550
var base_jump_velocity : float = 240
var jump_spd_increment : float = max_speed / 6
var jump_velocity : float = 200
var jump_h_boost : float = 2
var base_gravity : float = 600
var gravity : float = base_gravity
var floor_friction : float = 0.1
var air_friction : float = 1

var normal := Vector2.ZERO
var angle := 0.0

# Clocks
var jump_rq = -1
var jump_time = 0
var slide_cd = -1
var stairs_cd = -1
var attack_rq = -1

# Flags
var is_jumping = false
var is_sliding = false

var curr_anim = "idle"
var look_dir = 1

@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite
@onready var stairs_l_down = $Detectors/StairsLDown
@onready var stairs_r_down = $Detectors/StairsRDown
@onready var stairs_l_up = $Detectors/StairsLUp
@onready var stairs_l_mid = $Detectors/StairsLMid
@onready var stairs_r_up = $Detectors/StairsRUp
@onready var stairs_r_mid = $Detectors/StairsRMid

func _draw():
	return
	

func _physics_process(delta):
	queue_redraw()
	if get_floor_angle() < 1:
		angle = get_floor_angle()
	normal = get_floor_normal()
	
	# clocks
	stairs_cd -= delta
	slide_cd -= delta
	jump_rq -= delta
	jump_time += delta
	attack_rq -= delta
	
	# input
	var h_dir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	
	if Input.is_action_just_pressed("sprint"):
		max_speed = base_max_speed * sprint_mult
	if Input.is_action_just_released("sprint"):
		max_speed = base_max_speed
	if Input.is_action_pressed("jump"):
		gravity = base_gravity / 2.0
	else:
		gravity = base_gravity
	if Input.is_action_just_pressed("jump"):
		jump_time = 0
		jump_rq = 0.2
	if Input.is_action_just_pressed("attack"):
		attack_rq = 1
	if abs(get_floor_angle()) >= SHALLOW_SLOPE_ANGLE and Input.is_action_pressed("down") and is_on_floor():
		is_sliding = true
		slide_cd = 0.2
	if slide_cd < 0 or not is_on_floor():
		is_sliding = false
	if curr_anim == "attack":
		h_dir = 0
		jump_rq = -1
	
	# get slope type
	slope_dir = 1 if normal.x > 0 else -1
	
	var down_slope = true

	if angle >= STEEP_SLOPE_ANGLE:
		current_slope = STEEP_SLOPE_ANGLE 
	elif angle >= MEDIUM_SLOPE_ANGLE:
		current_slope = MEDIUM_SLOPE_ANGLE
	elif angle >= SHALLOW_SLOPE_ANGLE:
		current_slope = SHALLOW_SLOPE_ANGLE
	elif angle < SHALLOW_SLOPE_ANGLE:
		current_slope = FLAT_SLOPE
		slope_dir = 0
	
	if velocity.x > 0:
		
		down_slope = slope_dir > 0
	elif velocity.x < 0:
		down_slope = slope_dir < 0
	
	match (current_slope):
		SHALLOW_SLOPE_ANGLE:
			slope_mult = SHALLOW_DOWN_SPEED if down_slope else SHALLOW_UP_SPEED
		MEDIUM_SLOPE_ANGLE:
			slope_mult = MEDIUM_DOWN_SPEED if down_slope else MEDIUM_UP_SPEED
		STEEP_SLOPE_ANGLE:
			slope_mult = STEEP_DOWN_SPEED if down_slope else STEEP_UP_SPEED
		FLAT_SLOPE:
			slope_mult = 1.0
	
	# walk
	if abs(h_dir) < 0.2:
		var friction_mult = 1
		if is_sliding and sign(get_real_velocity().x) == sign(slope_dir):
			friction_mult = 90 / angle
		elif is_sliding and sign(get_real_velocity().x) != sign(slope_dir):
			friction_mult = 5 / angle
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, (max_speed / (floor_friction * friction_mult)) * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, (max_speed / (air_friction * friction_mult)) * delta)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, h_dir * max_speed * slope_mult, (max_speed / floor_h_accel) * slope_mult * delta)
		else:
			velocity.x = move_toward(velocity.x, h_dir * max_speed, (max_speed / air_h_accel) * delta)
			
	# gravity
	velocity.y = move_toward(velocity.y, fall_speed, gravity * delta)
		
	# jump
	var jumped_this_frame = false
	if jump_rq > 0:
		if is_on_floor():
			jump_rq = -1
			jumped_this_frame = true
			is_jumping = true
			floor_snap_length = 0
			velocity.y = - (jump_velocity + 1.5 * int(abs(velocity.x) / jump_spd_increment))
			if h_dir != 0:
				velocity.x = velocity.x * jump_h_boost
	
	
	move_and_slide()
	
	# slope slide
	
	if is_sliding and not jumped_this_frame:
		if current_slope == STEEP_SLOPE_ANGLE:
			velocity.y += 24 * 4 * delta * 100
			velocity.x += 30 * 1.5 * slope_dir * delta * 10
		elif current_slope == MEDIUM_SLOPE_ANGLE:
			velocity.y += 24 * 2 * delta * 100
			velocity.x += 30 * 1 * slope_dir * delta * 10
		elif current_slope == SHALLOW_SLOPE_ANGLE:
			velocity.y += 24 * 0.9 * delta * 100
			velocity.x += 30 * 0.6 * slope_dir * delta * 10
			
	# floor snap
	if not is_jumping and not is_sliding:
		apply_floor_snap()
		floor_stop_on_slope = true
		floor_snap_length = 10
	if is_jumping or is_sliding:
		floor_snap_length = 0
		if is_sliding and not is_jumping:
			floor_stop_on_slope = false
			floor_snap_length = 8
		is_jumping = not is_on_floor()
	
	# step
	var path_obstructed = move_and_collide(Vector2(h_dir, 0), true)

	if path_obstructed:
		if h_dir != 0:
			global_position += Vector2(0, -8)
			if not move_and_collide(Vector2(h_dir * 2, 0), true) and angle < SHALLOW_SLOPE_ANGLE:
				global_position += Vector2(h_dir * 2, 0)
				move_and_collide(Vector2(0, 8))
				apply_floor_snap()
			else:
				global_position -= Vector2(0, -8)
	
	# animation
	if curr_anim != "attack":
		if h_dir != 0:
			look_dir = h_dir
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
		if attack_rq > 0:
			curr_anim = "attack"
	if animation.current_animation != curr_anim:
		animation.play(curr_anim)
	
func attack_1():
	print("attack 1")
	
func attack_2():
	print("attack 2")

func attack_3():
	print("attack 3")
	
func attack_end():
	print("attack end")
	if attack_rq > 0:
		curr_anim = "attack"
	else:
		curr_anim = "idle"
