extends Node2D

var w = 50
var h = 50
var i = 0

var debug = true
const res = preload("res://node.tscn")
var debug_name = ""
var can_run = true
var auto_run = true
# Called when the node enters the scene tree for the first time.
func _ready():
#	var root = get_tree().get_root()
#
#	for x in w:
#		for y in h:
#			var node = res.instantiate()
#			node.name = "Node" + str(i)
#			node.position = Vector2(x*100, y*100)
#			if debug:
#				node.get_node("Id").text = node.name
#			self.add_child(node)
#			i+=1
#	var end_node = get_node("Node"+str(i-1)).position	
#	get_parent().get_node("Camera2D").position = end_node/2
	pass
	

#func _unhandled_input(event):
#	if event is InputEventKey:
#		var k = event.keycode
#		if k == 4194309 and event.pressed == false:
#
			
#
#			debug_name = ""
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_auto_run_button_toggled(button_pressed):
	auto_run = button_pressed


func _on_delay_text_changed(new_text):
	if new_text == "0":
		auto_run = true
