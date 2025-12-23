extends CharacterBody2D
@onready var health_bar = $"../CanvasLayer/TextureProgressBar" #adjust path for health bar
#export variables can be modified outside the script editor in the game engine 2d area thing itself
@export var speed: float = 380
@export var friction: float = 200
@export var accel: float = 500
@export var gravity: float = 440
@export var jump_speed: float = -400
@export var max_health: int = 100
var health: float = max_health
#constant maxJumps and jumps are for double jumps, as jumps is the number of jumps you have AT ANY TIME but max is the maximum jumps you can reach
const maxJumps = 2
var jumps = 0
var isJumpPressed = false #this one is self explanitory bc of the name
#canjump is for auto jumping when the player hits the floor (it's satisfying)
var canJump = true

signal health_changed(current, max)

func take_damage(amount: float):
	health -= amount
	health = clamp(health, 0, max_health)
	emit_signal("health_changed", health, max_health)

	if health <= 0:
		die()
		health = 100

func heal(amount: float):
	health += amount
	health = clamp(health, 0, max_health)
	emit_signal("health_changed", health, max_health)

func die():
	position.x = 59.695
	position.y = 261
	
	
#these methods/functions run once every frame so they fast
func _physics_process(delta):
	var inputDir := 0 #imput direction
	handleInput()
	velocity.y += gravity *delta #delta is the time between frames
	heal(0.1)
	move_and_slide()
	update_movement(delta)
	resetPos()
	
	if Input.is_key_pressed(KEY_A):
		inputDir += -1
	elif Input.is_key_pressed(KEY_D):
		inputDir += 1
	else:
		inputDir = 0
	var targetSpeed := inputDir * speed
	if targetSpeed != 0:
		velocity.x = move_toward(velocity.x, targetSpeed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	velocity.x = move_toward(velocity.x, targetSpeed, accel * delta)
	velocity.y += gravity * delta	
	
	if health_bar:
		health_bar.value = health

#everytjhinmg in here is about keyboard inputs and stuff
func handleInput():
	
	if Input.is_key_pressed(KEY_F):
		take_damage(1)
	if is_on_floor(): #the function is_on_floor is a bool predefined in a godot class
		jumps = 0 #your jumps are set to 0 every time you hit the floor (yes the game knows then you hit the floor using the gravity)
		canJump = true #every time you hit the floor, you can jump again. we will use this boolean later 
		
	if Input.is_action_pressed("jump") and is_on_floor() and canJump: #whenever W (w is defined as "jump" in the keybinds) is pressed, AND the player is on the floor, AND the bool canjump is true, do the following things:
		velocity.y = jump_speed #velocity on the Y axis will be set to the jump speed (-400)
		jumps += 1 #your jumps will be incremented by 1
		canJump = false #this disables this function from running so there are not two of the same functions running once you press W (the next function below this one also uses the W key for double jumping)
	
	if Input.is_action_just_pressed("jump") and jumps < maxJumps and not is_on_floor(): #once W is pressed AND the number of jumps you have are LESS than 2 AS WELL as not being on the floor, do the following:
		velocity.y = jump_speed #same as before
		jumps += 1 #same as before (this one doesnt set the canJump as false to make it possible to double jump)
	

	if not Input.is_action_pressed("jump"): #this is FUNDEMENTAL as if sets the canjump to true every frame the W key is not pressed. This makes it so thast you can keep jumping on the floor as long as you hold W, no matter if you double jumped or not
		canJump = true
	if Input.is_action_just_pressed("smash"):
		velocity.y = -jump_speed * 3
		
func resetPos(): #resets pos to 0,0 whenever r is pressed for debugging purposes
	if Input.is_key_pressed(KEY_R):
		position.x = 59.695
		position.y = 261

func update_movement(delta: float) -> void: #this is just there idk why but it has sm to do with delta (which is the fps kinda) and the game gets mad if i remove it
	pass
