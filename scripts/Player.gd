extends CharacterBody2D


const HIGH_SLOPE_ANGLE = 0.784
const MEDIUM_SLOPE_ANGLE = 0.463
const LOW_SLOPE_ANGLE = 0.24
const STAIRSTEP_CD = 0.1

# Movement
var max_speed = 145
var air_h_accel = max_speed / 0.45
var floor_h_accel = max_speed / 0.25
var fall_speed = 200
var jump_velocity = -350
var up_gravity = 9
var down_gravity = up_gravity * 1.5
var floor_friction = max_speed / 0.2
var air_friction = max_speed / 0.4


# Clocks
var jump_rq = -1
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

func is_on_stairs() -> bool:
	return ((stairs_r_mid.is_colliding() and not stairs_r_up.is_colliding()) or (stairs_l_mid.is_colliding() and not stairs_l_up.is_colliding()))

func _physics_process(delta):
	
	
	var normal = get_floor_normal()
	var angle = get_floor_angle()
	var real_vel = get_real_velocity()
	
	# clocks
	stairs_cd -= delta
	jump_rq -= delta
	# input
	velocity.y += down_gravity
	var h_dir = Input.get_axis("left", "right")
	if Input.is_action_just_pressed("jump"):
		jump_rq = 0.2
	if abs(get_floor_angle()) > LOW_SLOPE_ANGLE and Input.is_action_pressed("down") and is_on_floor():
		is_sliding = true
	# walk
	if abs(h_dir) < 0.2 and is_on_floor():
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, floor_friction * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, air_friction * delta)
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, h_dir * max_speed, floor_h_accel * delta)
		else:
			velocity.x = move_toward(velocity.x, h_dir * max_speed, air_h_accel * delta)

	# slope slide
	# stairs
	# jump
	# floor snap
	if not is_jumping and not is_sliding:
		apply_floor_snap()
		floor_snap_length = 10
	if is_jumping or is_sliding:
		floor_snap_length = 0
		is_jumping = not is_on_floor()
	move_and_slide()
	# animation
	if h_dir != 0:
		curr_anim = "walk"
	else:
		curr_anim = "idle"
	if animation.current_animation != curr_anim:
		animation.play(curr_anim)
	
