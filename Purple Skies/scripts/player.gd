extends CharacterBody2D

@export var speed: float = 200
@export var gravity: float = speed * 2
@export var jump_speed: float = -speed * 2

func _physics_process(delta):
	handle_input()
	velocity.y += gravity * delta   # simple gravity
	move_and_slide()                # moves using velocity
	update_movement(delta)

func handle_input():
	if Input.is_key_pressed(KEY_W) and is_on_floor():
		velocity.y = jump_speed
	var direction = Input.get_axis("KEY_A", "KEY_D")
	velocity.x = speed * direction
	
func update_movement(delta: float) -> void:
	pass
