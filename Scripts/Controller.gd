extends Node2D

var w = 4
var h = 4
var i = 0

var debug = true
const res = preload("res://node.tscn")
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
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
