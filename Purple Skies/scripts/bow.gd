extends Node2D
var arrowCount = 10
@export var maxPull := 200
@export var maxForce := 1400
@onready var swordScene:Node2D = $"../Sword"
@onready var playerScene: CharacterBody2D = $".."
const kMinAngle := -80
const kMaxAngle := 80
var currentForce = 0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D #sprite is animated bc we have separate anymation frames for the amount you pull back
@onready var arrowSpawn: Marker2D = $Marker2D #marker2d is where the arrow will spawn from the bow 
var canShoot = false
var pullAmount: float = 0 #initially, the pull amount is set to 0 but will change when you pull
var pulling: bool = false
var pullStartPos: Vector2 = Vector2.ZERO #the startpos is set to the 0,0 on the vector2 as the starting point


func _process(delta: float): #called each frame
	disable()
	var dir = -(get_global_mouse_position() - global_position)
	#pullAmount = clamp(dir.length() / maxPull, 0, 1)
	var rawAngle = dir.angle() #the direction is set to the dir variable and angle() converts it into RADIANS as that is what the ROTATION property requests
	var smoothAngle = lerp_angle(
		rotation,
		rawAngle,
		10 * delta
	) #clamp to ensure the bow doesnt go too far down or up
	rotation = softClamp(
		smoothAngle,
		deg_to_rad(kMinAngle),
		deg_to_rad(kMaxAngle),
		0.6666666667
	)
	drawCycle()

func drawCycle():
	if Input.is_action_just_pressed("draw"):
		startPull()
	if pulling:
		update()
	if Input.is_action_just_released("draw") and pulling and playerScene.swap_to_bow:
		release()

func startPull():
	pulling = true #sets pulling to true CRAZY IKR
	pullStartPos = get_global_mouse_position() #sets the start pos. used to calculate how far u pulled ts bow blud
	canShoot = false
	
func update():
	var currentMousePos = get_global_mouse_position() #makes the var CURRENTMOUSEPOS and sets it to the MOUSE POSITION woooooow so crazy
	var dist = pullStartPos.distance_to(currentMousePos) #gets the distance between the start of the pull and the current position
	pullAmount = clamp(dist / maxPull, 0, 1) #divides the two making a value. Then this value is put betyween 0 and 1 so if the two values were 200 and 400, it would be 0.5, meaning it would be set to 0.5 but if the quotient was 2, it would be set to 1 becase that is the maximum value.
	sprite.frame = int(pullAmount * 5) #pullAmount is a value between 0 and 1, so multiplyiong it by 5 will give you the frame that needs to be displayed. int() makes it so that numbers are whole numbers.

func disable():
	if !playerScene.swap_to_bow:
		visible = false
	else:
		visible = true
	
func release():
	arrowCount = clamp(arrowCount, -1, 10)
	if arrowCount <= -1:
		return
	print("arrows: ", arrowCount)
	pulling = false
	if pullAmount < 0.15:
		pullAmount = 0
		sprite.frame = 0
		return
	sprite.frame = 0
	fireArrow()
	pullAmount = 0
	


func fireArrow(): 
	arrowCount -= 1
	var arrowScene = preload("res://Purple Skies/scenes/Weapons/Arrow.tscn")
	var arrow = arrowScene.instantiate()
	get_tree().current_scene.add_child(arrow)

	arrow.power = pullAmount
	arrow.global_position = arrowSpawn.global_position

	var dir = Vector2.RIGHT.rotated(rotation)
	var force = pullAmount * maxForce

	arrow.linear_velocity = dir * force
	arrow.rotation = rotation
	arrow.angular_velocity = 0
	arrow.gravity_scale = 1
	arrow.angular_damp = 10
	
	if sprite.frame == 0:
		return


func softClamp(angle, minAngle, maxAngle, softness := 0.6):
	if angle < minAngle:
		return lerp_angle(angle, minAngle, softness)
	if angle > maxAngle:
		return lerp_angle(angle, maxAngle, softness)
	return angle
	
