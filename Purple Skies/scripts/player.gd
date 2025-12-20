extends CharacterBody2D

#export variables can be modified outside the script editor in the game engine 2d area thing itself
@export var speed: float = 200
@export var gravity: float = speed * 2
@export var jump_speed: float = -speed * 2
#constant maxJumps and jumps are for double jumps, as jumps is the number of jumps you have AT ANY TIME but max is the maximum jumps you can reach
const maxJumps := 2
var jumps := 0
var isJumpPressed = false #this one is self explanitory bc of the name
#canjump is for auto jumping when the player hits the floor (it's satisfying)
var canJump = true

#these methods/functions run once every frame so they fast
func _physics_process(delta):
	handleInput()
	velocity.y += gravity * delta   
	move_and_slide()
	update_movement(delta)

#everytjhinmg in here is about keyboard inputs and stuff
func handleInput():
	var direction = 0 #direction can either be 1 (right) or -1 (left) or 0 (not moving)
	
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
	
	if Input.is_key_pressed(KEY_A): #the next two if statements are for movement horizontally using A and D
		direction += -1
	if Input.is_key_pressed(KEY_D):
		direction += 1
	velocity.x = direction * speed #sets the velocity on the x axis as speed (which is 200) times the direction which is either 1 or -1
	
	if not Input.is_action_pressed("jump"): #this is FUNDEMENTAL as if sets the canjump to true every frame the W key is not pressed. This makes it so thast you can keep jumping on the floor as long as you hold W, no matter if you double jumped or not
		canJump = true

func update_movement(delta: float) -> void: #this is just there idk why but it has sm to do with delta (which is the fps kinda) and the game gets mad if i remove it
	pass
