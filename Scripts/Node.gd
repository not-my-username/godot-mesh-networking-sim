extends Sprite2D

var connected_devices = []
var active_packets = {}
var queue = [] 
var packets_handled = []
var broadcast_queue = []
var ready_to_broadcast = true
var data_to_send
var path_packet = {
	"to":"",
	"from":"",
	"id":0,
	"data_id":0,
	"path":[],
	"type":"path",
	"is_return":false,
	"last":""
}
var debug
var hover = false
# Called when the node enters the scene tree for the first time.
func _ready():
	debug = self.get_parent().debug
	self.get_node("Mesh Signal").area_entered.connect(_on_mesh_signal_area_entered)
	var shape = CircleShape2D.new()
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.set_shape(shape)
	collision.shape.radius = 0
	self.get_node("Mesh Signal").add_child(collision)

func _process(delta):
#	self.get_node("Distance").text = str(connected_devices)
	if len(queue) != 0 :
		data_to_send = {}
		if queue[0].type == "data":
			var item = queue[0].duplicate(true)
			data_to_send = path_packet.duplicate(true)
			data_to_send.to = item.to
			data_to_send.from = str(self.name)
			data_to_send.data_id = item.id
			data_to_send.id = randi_range(999999, 100000)
			data_to_send.path = [str(self.name)]
			active_packets[item.id] = item
			broadcast_queue.append(data_to_send)
			# Looking at where broadcast function was called from, thinking it is duplicating data again
		if queue[0].type == "path":
			var item = queue[0].duplicate(true) 
			if item.to in connected_devices:
				print(self.name, " Found Device Path Is Sent To")
				data_to_send = item
				data_to_send.path.append(str(self.name))
				data_to_send.id = randi_range(999999, 100000)
				data_to_send.is_return = true
				data_to_send.from = str(self.name)
				packets_handled.append(data_to_send.id)
				await get_tree().create_timer(0.1).timeout
				broadcast_queue.append(data_to_send)
			elif item.to == self.name:
				print("Receved Path Packet From: ", item.from)
			else:
				data_to_send = item.duplicate(true) 
				data_to_send.path.append(str(self.name))
				data_to_send.last = self.name
				broadcast_queue.append(data_to_send)
		queue.remove_at(0)
		
		if ready_to_broadcast:
			broadcast(broadcast_queue[0])
			broadcast_queue.remove_at(0)	
			print("Queue For: ", self.name, ": ", broadcast_queue)
		
func send(data, from):
	if debug:
		print(data)
	queue.append(data)
	
func broadcast(data):
	ready_to_broadcast = false
	if data.is_return:
		print("Returning: ", data)
	print("Sending Data From: ", self.name)
	self.get_node("Mesh Signal/CollisionShape2D").set_meta("data", data)
	self.get_node("Mesh Signal/CollisionShape2D").shape.radius = 65
	await get_tree().create_timer(0.1).timeout
	self.get_node("Mesh Signal/CollisionShape2D").shape.radius = 0
	ready_to_broadcast = true	

func add_connection(node):
	if node.name not in connected_devices:
		connected_devices.append(node.name)
		print(self.name, " Has Connected To: ", node.name)


func remove_connection(node):
	if node.name in connected_devices:	
		connected_devices.erase(node.name)
		print(self.name, " Has Dissconnected From: ", node.name)	

func _on_area_2d_area_entered(area):
	if area.name == "Mesh Signal" and area != $"Mesh Signal":
		var data = area.get_node("CollisionShape2D").get_meta("data")
		if data.id not in packets_handled:
			if data.is_return and self.name not in data.path:
				return
			else:
				packets_handled.append(data.id)
				queue.append(data)		
				print(self.name, " Receved Data From: ", area.get_parent().name)
		else:
			if debug:			
				print(self.name, " Has already has this packet from: ", area.get_parent().name, ": Packets Handled: ", packets_handled)
#	elif area.name == "Wireless Signal":
#		print(self.name, " Has Connected To: ", area.get_parent().name)
#		connected_devices.append(area.get_parent().name)

func _on_area_2d_area_exited(area):
#	if area.name == "Wireless Signal":
#		print(self.name, " Lost Conected To: ", area.get_parent().name)
#		connected_devices.erase(area.get_parent().name)
	pass

func _on_mesh_signal_area_entered(area):
#	if area.name == "Node Box" and area != $"Node Box":
#		if debug:		
#			print("Mesh Signal Found: ", area.get_parent().name)
	pass

func _on_mesh_signal_area_exited(area):
#	if area.name == "Mesh Signal":
#		return
	pass
