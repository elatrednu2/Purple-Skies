extends Sprite2D


func _ready() -> void:
	var mouse_pos = get_global_mouse_position() # finds the position of the mouse
	global_position = mouse_pos
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position() # finds the position of the mouse
	global_position = mouse_pos
	rotation += 3*(PI/180)
