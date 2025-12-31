extends Area2D

@export var damage := 10

var can_hit := true

func _ready():
	monitoring = false
	body_entered.connect(_on_body_entered)

func _process(_delta):
	if Input.is_action_just_pressed("hit") and can_hit:
		swing()

func swing():
	can_hit = false
	monitoring = true
	await get_tree().create_timer(0.1).timeout
	monitoring = false
	can_hit = true

func _on_body_entered(body):
	if body.has_method("takeDamage"):
		body.takeDamage(damage)
		print("Hit", body.name, "for", damage)
		
