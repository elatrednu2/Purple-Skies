extends Camera2D
@export var randomStrength: float = 20
@export var shakeFade: float = 29
@onready var player = get_parent()
var rng = RandomNumberGenerator.new()
var shakeStrength: float = 0
var shake = true
var timer: Timer
var timerStart = false

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1
	timer.one_shot = true
	timer.timeout.connect(_on_my_timer_timeout)
	

func _on_my_timer_timeout():
	shake = false
	timerStart = false

func applyShake():
	shakeStrength = randomStrength + abs(player.velocity.y)

	
func _process(_delta):
	if Input.is_action_just_pressed("smash") and not player.is_on_floor():
		timerStart = true
	if shakeStrength > 0:
		shakeStrength = lerpf(shakeStrength, 0 , shakeFade * _delta)
		offset = rancomOffset()
	if timerStart == true and player.is_on_floor() and shake == true:
		applyShake()
		timerStart = false

		
func rancomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))
