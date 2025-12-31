extends Node2D
@onready var playerScene: CharacterBody2D = $".."

func _process(delta: float) -> void:
	pass
	toggleSword()
	
func toggleSword():
	if playerScene.swap_to_bow:
		visible = false
	else: visible = true


	
