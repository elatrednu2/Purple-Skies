extends CharacterBody2D

#TODO: please tune gravity and other physics
#TODO: make sure the special jump movement thing works because I am not certain

@onready var healthBar = $"Health Bar"
@onready var bowScene = $Bow
@export var swap_to_bow := true
signal health_changed(current: int, max: int)

# playerState
var playerState: String

#region movement variables
#movement
@export var speed := 900.0
@export var sprintMultiplier := 1.4
@export var accel := 800.0
@export var friction := 3000
#endregion

#region gravity variables
#gravity
@export var baseGravity := 2000.0
@export var jumpSpeed := -2400.0
@export var terminalVelocity := 4000.0
#endregion

#timers
@export var coyoteTime := 0.125
@export var doubleJumpCooldown := 0.5

var was_on_floor := false
var on_floor: bool

#region health variables
#health
@export var maxHealth := 100
var health: int
#endregion

#more jumps
var autoHops := false
var doubleJumpsEnabled:= false
var allowJumpsEnabled: bool
var isJumpHeld := false
var toQueueJump := false
@export var jumpCut := 0.75 # there will be another place where jumpCut is assigned
# because i tried making it only one place but that ruins the smashing for some reason
var jumpCutBool: bool
@export var peak:= -1000

#timers
var coyoteTimer: Timer

#gravity modifiers
@export var gravityMultiplier := 1.0
@export var fastFallGravity := 2.4

#debug
@export var hurtAmount := true

func _ready():
	health = maxHealth
	coyoteTimer = Timer.new()
	coyoteTimer.one_shot = true
	add_child(coyoteTimer)

#cleaned up this func a LOT
func _physics_process(delta):
	handle_movement(delta)
	handle_gravity(delta)
	move_and_slide()
	handle_floor_state();
	_healthBarFormat();
	
func _input(event: InputEvent):
	handle_input()
		
func _healthBarFormat():
	if healthBar:
		healthBar.value = health;

func handle_input():
	debug()
	input()

func debug():
	doubleJump()
	resetPos()
	hurtSelf(hurtAmount)

func input():
		#there has to be a better way to do this than if statements bc if statements are baaaaaad
	if Input.is_action_pressed("jump"):
		autoHops = true
	else:
		autoHops = false
	if Input.is_action_just_pressed("swap"):
		swap_to_bow = !swap_to_bow
	if Input.is_action_just_pressed("jump"):
		isJumpHeld = true
		if doubleJumpsEnabled:
			do_jump()
			doubleJumpsEnabled = false
			await get_tree().create_timer(doubleJumpCooldown).timeout
			if not on_floor:
				doubleJumpsEnabled = true
		if not toQueueJump:
			toQueueJump = true
			await get_tree().create_timer(coyoteTime).timeout
			toQueueJump = false
	if Input.is_action_just_released("jump"):
		isJumpHeld = false
		if playerState == "jumping":
			jumpCutBool = true
#velocity.y > peak
	if Input.is_action_pressed("smash"):
		playerState = "smashing"
		
func stopTimers():
	coyoteTimer.stop()

#mov
func handle_movement(delta):
	#bind these keys if not done already
	var input_dir := Input.get_action_strength("moveRight") - Input.get_action_strength("moveLeft")
	var target_speed := speed
	var friction_force := friction
	if not is_on_floor:
		friction_force *= 0.25
	
	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * target_speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction_force * delta)

	if toQueueJump or isJumpHeld:
		if can_jump():
			do_jump()
			toQueueJump = false

# ATT at physics
func handle_gravity(delta):
	var gravity := baseGravity
	# Fast fall (only when falling)
	if velocity.y > 0:
		if playerState == "falling":
			gravityMultiplier = 1.1
		elif playerState == "smashing":
			gravityMultiplier = fastFallGravity
		print(velocity.y)
	else:
		gravityMultiplier = 1.0

	if velocity.y > 0 and playerState != "smashing":
		playerState = "falling"
	elif velocity.y < 0 and playerState != "smashing":
		playerState = "jumping"
		
	velocity.y += gravity * delta
	velocity.y *= gravityMultiplier
	
	if jumpCutBool:
		velocity.y *= jumpCut*gravityMultiplier
		jumpCutBool = !jumpCutBool
	
	if velocity.y >= terminalVelocity*gravityMultiplier:
		velocity.y = terminalVelocity*gravityMultiplier
	
	if velocity.y < 0 and playerState == "smashing":
		velocity.y = 0

# coyote time attempt
func handle_floor_state():
	if is_on_floor():
		jumpCutBool = false
		on_floor = true
		gravityMultiplier = 1.0
		playerState	= "walking"
		coyoteTimer.stop()
	else:
		on_floor = false
		if was_on_floor:
			coyoteTimer.start(coyoteTime)
	was_on_floor = is_on_floor()

# more jump logic (fixed coyote time)
func can_jump():
	if on_floor:
		return true
	elif coyoteTimer.time_left > 0:
		return true
	return false

func do_jump():
	playerState = "jumping"
	velocity.y = jumpSpeed
	if not on_floor and coyoteTimer.time_left <= 0:
		allowJumpsEnabled = true
	velocity.y = jumpSpeed
	coyoteTimer.stop()

func take_damage(amount: int):
	health = clamp(health - amount, 0, maxHealth)
	emit_signal("health_changed", health, maxHealth)

	if health <= 0:
		die()

func die():
	position = Vector2(59.695, 261)
	health = maxHealth

func doubleJump():
	if Input.is_key_pressed(KEY_K):
		doubleJumpsEnabled = !doubleJumpsEnabled
		print(doubleJumpsEnabled)

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
