extends Area2D #we use area2d because its detects bodies entering and exiting and stuff like that yo.

@export var damage := 10

func _ready() -> void: #_ready() runs at beginning once
	body_entered.connect(_on_body_entered) #commects the boolean "body_entered" to the function below so it can activate on body entering.
	
func _on_body_entered(body): #whenever a body of the type "body" enters the hitbox
	if body.has_method("take_damage"):
		body.take_damage(damage) #the body takes damage as long as it has a methos called "take_damage"
