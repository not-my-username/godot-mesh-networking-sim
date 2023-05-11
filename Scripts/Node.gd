extends Node2D

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
var data_packet = {
	"to":"",
	"from":"",
	"data":"",
	"id":0,
	"path":[],
	"type":""
}

var known_paths = {
	
}
var debug
var hover = false
var texture_node

# Animation Varibals 

var emmit_animation_running = false
var packet_animation_opening = false

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
	texture_node = $Texture
	

func _process(delta):
#	self.get_node("Distance").text = str(connected_devices)
	if self.get_parent().auto_run and self.get_parent().can_run:
		run_mesh()
	elif self.get_parent().can_run and Input.is_action_just_pressed("enter"):
		run_mesh()
		
func run_mesh():
		
	if ready_to_broadcast and len(broadcast_queue) !=0:
		await broadcast(broadcast_queue[0])
		emmit_animation()
		broadcast_queue.erase(broadcast_queue[0])
		if len(broadcast_queue) == 0 and len(queue) == 0:
			has_packet_animation_close()
		
	
	if len(queue) != 0 :
		data_to_send = {}
		if queue[0].type == "data":
			var item = queue[0].duplicate(true)
			if item.from in connected_devices:
				if item.to in known_paths:
					data_to_send = item
					data_to_send.path = known_paths[item.to]
					packets_handled.append(data_to_send.id) 					
					broadcast_queue.append(data_to_send)					
				else:
					data_to_send = path_packet.duplicate(true)
					data_to_send.to = item.to
					data_to_send.from = str(self.name)
					data_to_send.data_id = item.id
					data_to_send.id = randi_range(999999, 100000)
					data_to_send.path = [str(self.name)]
					active_packets[item.id] = item
					packets_handled.append(data_to_send.id)
					broadcast_queue.append(data_to_send)
			if item.to in connected_devices:
				get_tree().root.get_child(0).get_node(item.to).receive(item)
			else:
				data_to_send = item
				packets_handled.append(data_to_send.id)
				broadcast_queue.append(data_to_send)
				
		if queue[0].type == "path":
			var item = queue[0].duplicate(true) 
			if item.to in connected_devices:
				data_to_send = item.duplicate(true) 
				data_to_send.path.append(str(self.name))
				data_to_send.id = randi_range(999999, 100000)
				packets_handled.append(data_to_send.id)
				data_to_send.is_return = true
				data_to_send.to = data_to_send.from
				data_to_send.from = str(item.to)
#				await get_tree().create_timer(0.1).timeout
				broadcast_queue.append(data_to_send)
			elif item.to == self.name:
#				print("\n\n\n\n\n")
#				print(self.name, " Receved Path Packet From: ", item.from)
#				print(item)
#				print("\n\n\n\n\n")
				known_paths[item.from] = item.path 
				if len(broadcast_queue) == 0 and len(queue) == 0:
					has_packet_animation_close()
				
				print(self.name, " Active Packets: ", active_packets)
				data_to_send = active_packets[item.data_id]
				data_to_send.path = item.path
				active_packets.erase(item.data_id)
				packets_handled.append(data_to_send.id)
				broadcast_queue.append(data_to_send)
				
			else:
				data_to_send = item.duplicate(true)
				if not item.is_return:
					data_to_send.path.append(str(self.name))
				data_to_send.last = self.name
				broadcast_queue.append(data_to_send)
		
		
		if len(queue) != 0:
			queue.remove_at(0)
			if len(broadcast_queue) == 0 and len(queue) == 0:
				has_packet_animation_close()
#	if len(broadcast_queue) == 0 and len(queue) == 0:
#			has_packet_animation_close()
				
func send(data, from):
	queue.append(data)
	has_packet_animation_open()
	
func broadcast(data):
	ready_to_broadcast = false
	self.get_node("Mesh Signal/CollisionShape2D").set_meta("data", data)
	self.get_node("Mesh Signal/CollisionShape2D").shape.radius = 65
	await get_tree().create_timer(0.1).timeout
	self.get_node("Mesh Signal/CollisionShape2D").shape.radius = 0
	ready_to_broadcast = true

func add_connection(node):
	if node.name not in connected_devices:
		connected_devices.append(node.name)
		texture_node.texture = load("res://Textures/Node/node-device-connected.png")

func remove_connection(node):
	if node.name in connected_devices:	
		connected_devices.erase(node.name)
		if len(connected_devices) == 0:
			texture_node.texture = load("res://Textures/Node/node.png")

func _on_area_2d_area_entered(area):
	if area.name == "Mesh Signal" and area != $"Mesh Signal":
		var data = area.get_node("CollisionShape2D").get_meta("data")
		if data.id not in packets_handled:
			if data.type == "path":
				if data.is_return and self.name not in data.path:
					return
			elif data.type == "data":
				if data.type == "data" and self.name not in data.path:
					return
			packets_handled.append(data.id)
			queue.append(data)
			has_packet_animation_open()
			
				
		
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

func emmit_animation():
	if $Emmit.visible:
		return
	$Emmit.visible = true
	var speed = 0
	if get_parent().auto_run:
		speed = 0.08
	else: 
		speed = 0.05
		
	var i = 0.07
	while i < .7:
		$Emmit.scale = Vector2(i, i)
		await get_tree().create_timer(0.01).timeout	
		i += speed
		
	while i > 0.07:
		$Emmit.scale = Vector2(i, i)
		await get_tree().create_timer(0.01).timeout	
		i -= speed
		
	$Emmit.visible = false

func has_packet_animation_open():
	if $Packet.visible:
		return
	packet_animation_opening = true
	$Packet.visible = true
	
	var i = 0.07
	while i < .15:
		$Packet.scale = Vector2(i, i)
		await get_tree().create_timer(0.01).timeout	
		i += 0.02
	packet_animation_opening = false
	
func has_packet_animation_close():
		
	var i = .15
	while i > 0:
		$Packet.scale = Vector2(i, i)
		await get_tree().create_timer(0.01).timeout	
		i -= 0.02
		
	$Packet.visible = false
