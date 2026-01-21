extends RigidBody2D #this node attached to a rigid body (credits to zilin bc i was using characterbody before and it was bad)

@export var gravtitty := 10000 
@export var speed := 1500
@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var hitbox2: CollisionShape2D = $CollisionShape2D2
@onready var hitbox3: CollisionShape2D = $Area2D/CollisionShape2D
@onready var hitbox4: CollisionShape2D = $Area2D/CollisionShape2D2
var stuckTo: Node2D = null
var stuck: bool = false #this was made from me lwk not knowing how to make the arrow stop spinning on contact with the ground
@export var hitboxDelay := 0.01
@export var despawnTime = 3
@export var arrowDamage := 10
var power:float = 0
var hasHit = false
var timerStarted = false

func _on_body_entered(body):
	sleeping = true
	enableHitbox()
	
func _ready(): #things in _ready() run once in the beginnning
	var arrowHitbox: Area2D = $Area2D
	arrowHitbox.damage = getDamage()
	angular_damp = 10 #angular damp is the decceleration of the arrow thru the air so it doesnt travel forever. 
	enableHitbox()
	var timer: Timer = Timer.new() #makes a timer so the hitbox enables after 0.1 seconds
	timer.wait_time = hitboxDelay #wait time config
	timer.one_shot = true #timer stops after reaching end. without thi, timer restarts
	timer.timeout.connect(func(): disableHitbox())
	add_child(timer)
	timer.start()
		
func enableHitbox():
	hitbox.disabled = true #sets hitbox as disabled when starting to prevent hitbox collision with player\
	hitbox2.disabled = true
	hitbox3.disabled = true
	hitbox4.disabled = true
func disableHitbox():
	hitbox.disabled = false
	hitbox2.disabled = false
	hitbox3.disabled = false
	hitbox4.disabled = false
	
	
func _on_area_2d_body_entered(body):
	if stuck:
		return
	if body is CharacterBody2D:
		stickToBody(body)
		
	if body.has_method("stopSpin") || is_in_group("Arrows") || is_in_group("floor"):
		stickDespawn()

	if body.has_method("takeDamage"):
		var dmg = getDamage()  # <-- call arrow's own getDamage()
		body.takeDamage(dmg)
		hasHit = true

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
	

	
func _physics_process(_delta): #again, delta means it runs once every frame and _physics_process has all the commands regarding physics
	if stuck:
		return
	if linear_velocity.length() > 1:
		rotation = linear_velocity.angle()
	
func getDamage() -> float:
	var t:float = clamp(power, 0.0, 1.0)
	var curved:float = t * t + 0.2 * t
	return arrowDamage * curved
	
func stickToBody(body: Node2D):
	stuck = true
	stuckTo = body

	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	gravity_scale = 0

	# Keep world position
	var global_xform = global_transform

	# Reparent to body
	get_parent().remove_child(self)
	body.add_child(self)

	# Restore world position
	global_transform = global_xform

	hitbox.disabled = true
	hitbox2.disabled = true
	hitbox3.disabled = true
	hitbox4.disabled = true

	despawnTimer()
	

	
	
		

	

	
	
