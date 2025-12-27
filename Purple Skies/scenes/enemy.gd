extends StaticBody2D  # or CharacterBody2D if it moves

@export var max_health := 100
var health :float = max_health

signal health_changed(current, max)

func takeDamage(amount: float):
	health -= amount
	health = clamp(health, 0, max_health)
	emit_signal("health_changed", health, max_health)
	print("name: ", name, "damage: ", amount, "current health: ", health)
	
	if health <= 0:
		die()

func die():
	print(name, "he ded :(")
	health = 100
	
func stopSpin():
	pass
