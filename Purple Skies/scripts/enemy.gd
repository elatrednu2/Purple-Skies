extends StaticBody2D  # or CharacterBody2D if it moves

@export var max_health := 100
var health :float = max_health
@onready var colorR = $ColorRect
@onready var textDisplay = $LineEdit
signal health_changed(current, max)
var timer: Timer

func _process(delta: float) -> void:
	textDisplay.text = str(int(health))

func takeDamage(amount: float):
	health -= amount
	health = clamp(health, 0, max_health)
	emit_signal("health_changed", health, max_health)
	print("name: ", name, " ", "damage: ", amount, " ", "current health: ", health)
	
	if health <= 0:
		die()
		resetColor()

func die():
	print("he ded :(")
	health = 100
	textDisplay.text
	colorR.color = Color(0.0, 0.0, 0.945, 1.0)

func stopSpin():
	pass
	
func resetColor():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2
	timer.one_shot = true
	timer.timeout.connect(func(): colorR.color = Color(1.0, 1.0, 1.0, 1.0))
	timer.start()
	
