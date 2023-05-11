extends LineEdit

var camrea_node
var controller 
# Called when the node enters the scene tree for the first time.
func _ready():
	camrea_node = get_parent().get_parent().get_parent().get_parent()
	controller = get_tree().root.get_child(0).get_node("Controller")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
