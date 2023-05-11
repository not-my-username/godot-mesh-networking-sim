extends LineEdit

var is_active = false
var fps_node
var camrea_node
var controller 
var history = []
var history_index = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	fps_node = get_parent().get_node("FPS")
	camrea_node = get_parent().get_parent().get_parent()
	controller = get_tree().root.get_child(0).get_node("Controller")
	print(controller)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("open_console") and not is_active:
		self.visible = true
		is_active = true
		self.grab_focus()
		fps_node.visible = false
		camrea_node.can_move = false
		controller.can_run = false
	if Input.is_action_just_pressed("esc") and is_active:
		self.visible = false
		is_active = false
		fps_node.visible = true
		camrea_node.can_move = true
		controller.can_run = true		
	if Input.is_action_just_pressed("enter") and is_active:
		run_command(self.text)
		history.append(self.text)
		history_index = -1
		self.text = ""
	
	
func _unhandled_input(event):
	if event is InputEventKey and is_active:
		if event.keycode == 4194320:
			history_index += 1
			if history_index > len(history)-1: history_index = len(history) - 1
			self.text = history[history_index]
			self.set_caret_column(len(self.text))
		if event.keycode == 4194322:
			history_index -= 1
			if history_index < 0: history_index = 0		
			self.text = history[history_index]
			self.set_caret_column(len(self.text))
	

func run_command(text):
	var split_text = text.split(" ")
	if split_text[0] == "get":
		print(split_text[1].right(-1))
		print(get_tree().root.get_child(0).get_node("Controller").get_node(split_text[1].right(-1)).get(split_text[2]))
	elif split_text[0] == "clear-broadcast-queue":
		for N in get_tree().root.get_child(0).get_node("Controller").get_children():
			N.broadcast_queue = []
			print("Cleared Broadcast Queue For: ", N.name)
	elif split_text[0] == "open":
		for N in get_tree().root.get_child(0).get_node("Controller").get_children():
			N.has_packet_animation_open()
		
	else:
		print("Unknown Command: ", split_text[0])

func _on_text_changed(new_text):
	pass # Replace with function body.
