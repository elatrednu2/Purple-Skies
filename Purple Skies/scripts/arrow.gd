extends RigidBody2D #this node attached to a rigid body (credits to zilin bc i was using characterbody before and it was bad)

@export var gravtitty := 10000 
@export var speed := 1200
@onready var hitbox: CollisionShape2D = $CollisionShape2D
var stuck: bool = false #this was made from me lwk not knowing how to make the arrow stop spinning on contact with the ground
@export var hitboxDelay := 0.1
@export var despawnTime = 3

func _ready(): #things in _ready() run once in the beginnning
	angular_damp = 10 #angular damp is the decceleration of the arrow thru the air so it doesnt travel forever. 
	hitbox.disabled = true #sets hitbox as disabled when starting to prevent hitbox collision with player
	
	var timer: Timer = Timer.new() #makes a timer so the hitbox enables after 0.1 seconds
	timer.wait_time = hitboxDelay #wait time config
	timer.one_shot = true #timer stops after reaching end. without thi, timer restarts
	timer.timeout.connect(func():
		hitbox.disabled = false
	)
	add_child(timer)
	timer.start()
	


func _on_area_2d_body_entered(body):
	if stuck:
		return
	if body.is_in_group("floor"):
		stickDespawn()
		
func _on_body_entered(body):
	if stuck:
		return
	if body.is_in_group("floor"):
		stickDespawn()
		
func stickDespawn():
	stuck = true
	freeze = true #stops all physdics ENTIRELY
	hitbox.disabled = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	gravity_scale = 0
	despawnTimer()
	
func despawnTimer():
	var despawn = Timer.new()
	despawn.wait_time = despawnTime
	despawn.one_shot = true
	despawn.timeout.connect(func(): queue_free())
	add_child(despawn)
	despawn.start()
	

	
func _physics_process(delta): #again, delta means it runs once every frame and _physics_process has all the commands regarding physics
	if stuck:
		return
	if linear_velocity.length() > 1:
		rotation = linear_velocity.angle()

		

	

	
	
