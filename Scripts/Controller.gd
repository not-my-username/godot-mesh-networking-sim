extends Node2D

var w = 4
var h = 4
var i = 0

var debug = true
const res = preload("res://node.tscn")
var debug_name = ""
var can_run = true
# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_tree().get_root()
	for x in w+1:
		for y in h+1:
			var node = res.instantiate()
			node.name = "Node" + str(i)
			node.position = Vector2(x*100, y*100)
			if debug:
				node.get_node("Id").text = node.name
			self.add_child(node)
			i+=1
			
#func _unhandled_input(event):
#	if event is InputEventKey:
#		var k = event.keycode
#		if k >= 48 and k <= 57 and event.pressed == false:
#			debug_name += str(k - 48)
##			print(debug_name) 
#		if k == 4194309 and event.pressed == false:
#			var debug_node = get_node("Node" + debug_name)
#			print(debug_node)
#
#			debug_name = ""
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
