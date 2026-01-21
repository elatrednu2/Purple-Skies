extends CharacterBody2D

#TODO: please tune gravity and other physics
#TODO: make sure the special jump movement thing works because I am not certain

@onready var healthBar = $"Health Bar"
@onready var bowScene = $Bow
@export var swap_to_bow := true
signal health_changed(current: int, max: int)


#movement
@export var speed := 900.0
@export var sprintMultiplier := 1.4
@export var accel := 800.0
@export var friction := 3000

#gravity
@export var baseGravity := 600.0
@export var jumpSpeed := -600.0
@export var jumpCutMultiplier := 3.0

#coyote time
@export var coyoteTime := 0.12
@export var jumpBufferTime := 0.12
var was_on_floor := false

#health
@export var maxHealth := 100
var health: int

#more jumps
var autoHops := false
const maxJumps := 2
var jumps := 0
var isJumpHeld := false

#timers
var coyoteTimer: Timer
var jumpBufferTimer: Timer

#gravity modifiers
var gravityMultiplier := 1.0
@export var hangGravity := 0.6
@export var fastFallGravity := 9

#debug
@export var hurtAmount = true

func _ready():
	health = maxHealth

	coyoteTimer = Timer.new()
	coyoteTimer.one_shot = true
	add_child(coyoteTimer)

	jumpBufferTimer = Timer.new()
	jumpBufferTimer.one_shot = true
	add_child(jumpBufferTimer)

#cleaned up this func a LOT
func _physics_process(delta):
	handle_input()
	handle_movement(delta)
	handle_gravity(delta)
	move_and_slide()
	handle_floor_state()

	if healthBar:
		healthBar.value = health

func handle_input():
	resetPos()
	hurtSelf(hurtAmount)
	
	#there has to be a better way to do this than if statements bc if statements are baaaaaad
	if Input.is_action_pressed("jump"):
		autoHops = true
	else:
		autoHops = false
	if Input.is_action_just_pressed("swap"):
		swap_to_bow = !swap_to_bow
	if Input.is_action_just_pressed("jump"):
		isJumpHeld = true
		jumpBufferTimer.start(jumpBufferTime)

	if Input.is_action_just_released("jump"):
		isJumpHeld = false

	if can_jump() and (jumpBufferTimer.time_left > 0 or autoHops):
		do_jump()
		jumpBufferTimer.stop()

	if Input.is_action_pressed("smash") and velocity.y > 0:
		gravityMultiplier = fastFallGravity
	else:
		gravityMultiplier = 1.0

#mov
func handle_movement(delta):
	#bind these keys if not done already
	var input_dir := Input.get_action_strength("moveRight") - Input.get_action_strength("moveLeft")

	var target_speed := speed
	var friction_force := friction
	if not is_on_floor():
		friction_force *= 0.25

	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * target_speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction_force * delta)

# ATT at physics
func handle_gravity(delta):
	var gravity := baseGravity

	# Jump cut (release jump while rising)
	if velocity.y < 0 and not isJumpHeld:
		gravity *= jumpCutMultiplier

	# Fast fall (only when falling)
	elif velocity.y > 0 and Input.is_action_pressed("smash"):
		gravity *= fastFallGravity

	velocity.y += gravity * delta

# coyote time attempt
func handle_floor_state():
	if is_on_floor():
		jumps = 0
		coyoteTimer.stop()
	else:
		if was_on_floor:
			coyoteTimer.start(coyoteTime)
	was_on_floor = is_on_floor()

# more jump logic (fixed coyote time)
func can_jump():
	if is_on_floor():
		return true
	if coyoteTimer.time_left > 0:
		return true
	return false

func do_jump():
	velocity.y = jumpSpeed
	if not is_on_floor() and coyoteTimer.time_left <= 0:
		jumps += 1
	coyoteTimer.stop()

func take_damage(amount: int):
	health = clamp(health - amount, 0, maxHealth)
	emit_signal("health_changed", health, maxHealth)

	if health <= 0:
		die()

func die():
	position = Vector2(59.695, 261)
	health = maxHealth





#debug
func resetPos():
	if Input.is_key_pressed(KEY_R):
		position = Vector2(59.695, 261)
		get_tree().call_group("arrows", "queue_free")
		bowScene.arrowCount = 10
		velocity = Vector2.ZERO
		
func hurtSelf(switch: bool):
	if switch == true:
		if Input.is_key_pressed(KEY_F):
			take_damage(3)

func stopSpin():
	pass
