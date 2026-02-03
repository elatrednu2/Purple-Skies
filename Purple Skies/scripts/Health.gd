extends TextureProgressBar

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	player.health_changed.connect(update_health)

	max_value = player.maxHealth
	value = player.health
	
	visible = true

func update_health(current, max_health):
	max_value = max_health
	value = current
