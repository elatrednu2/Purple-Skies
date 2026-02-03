extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var input: LineEdit = $Panel/LineEdit

var isOpen := false

# COMMAND REGISTRY
var commands := {}

func _ready():
	panel.visible = false
	input.text_submitted.connect(_onCommandEntered)

	# register commands here
	registerCommand("resetArrows", resetArrows)

func _process(_delta):
	# toggle console with `
	if Input.is_action_just_pressed("debugConsole"):
		toggle()

func toggle():
	isOpen = !isOpen
	panel.visible = isOpen

	if isOpen:
		input.grab_focus()
	else:
		input.release_focus()

func registerCommand(name: String, fn: Callable):
	commands[name.to_lower()] = fn

func _onCommandEntered(text: String):
	var cmd = text.strip_edges().to_lower()
	input.clear()

	if cmd == "":
		return

	if commands.has(cmd):
		commands[cmd].call()
		print("[DEBUG] Ran command:", cmd)
	else:
		print("[DEBUG] Unknown command:", cmd)

# -------------------------
# COMMANDS
# -------------------------

func resetArrows():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("Bow"):
		player.get_node("Bow").arrowCount = 10
		print("Arrows reset to 10")
