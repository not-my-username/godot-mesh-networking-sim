extends Node2D

var hover = false
var move = false
var nodes_in_range = []
var none_nodes = ["Mouse Box", "Wall", "Wireless Signal", "Mesh Signal"]
var nearest_node
var last_distance
var packet = {
	"to":"",
	"from":"",
	"data":"",
	"id":0,
	"path":[],
	"type":""
}
@onready var rayCast2D = $RayCast2D
@onready var console = get_tree().root.get_child(0).get_node("Camera2D/CanvasLayer/Control/Console")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("leftClick") and hover:
		move = true
	if Input.is_action_just_released("leftClick") and hover:
		move = false
	if move:
		self.position = get_global_mouse_position()
		
	if Input.is_action_just_pressed("space") and console.is_active == false:
			print("Sending Data")
			if nearest_node:
				packet.to = "Server"
				packet.from = "Computer"
				packet.data = "Hello From Computer"
				packet.id = randi_range(999999, 100000)
				packet.type = "data"
				nearest_node.get_parent().send(packet, self)

	if move and len(nodes_in_range) != 0:
		nearest_node = nodes_in_range[0]

		for node in nodes_in_range: 
			node.get_parent().remove_connection(self)			
			var distance_to_node = node.global_position.distance_to(self.position)
			
			if get_parent().get_node("Controller").debug:
				node.get_parent().get_node("Distance").text = str(round(distance_to_node))
			if distance_to_node <= nearest_node.global_position.distance_to(self.position):
				if node in nodes_in_range:

					nearest_node = node
		if nearest_node:
			nearest_node.get_parent().add_connection(self)

#		for i in range(0, 200):
#			$"Wireless Signal/CollisionShape2D".shape.radius = i
#			await get_tree().create_timer(0.01).timeout

func _on_area_2d_mouse_entered():
	hover = true

func _on_area_2d_mouse_exited():
	hover = false

func _on_wireless_signal_area_entered(area):
	if area.name == "Node Box":
		nodes_in_range.append(area)

func _on_wireless_signal_area_exited(area):
	if area.name == "Node Box":
		nodes_in_range.erase(area)
		area.get_parent().get_node("Distance").text = ""
		area.get_parent().remove_connection(self)
		if area == nearest_node:
			nearest_node = null
