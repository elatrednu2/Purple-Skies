extends Area2D

@export var damage := 10

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(10)
