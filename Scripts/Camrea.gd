extends Camera2D

var speed = 3
var velocity = Vector2(0, 0)
var zoom_velocity = Vector2(0, 0) 
var boost = 1
var can_move = true

func _process(delta):
	if Input.is_action_pressed("up") and can_move:
		velocity.y =- speed * boost
	if Input.is_action_pressed("down") and can_move:
		velocity.y = speed * boost
	if Input.is_action_pressed("left") and can_move:
		velocity.x =- speed * boost
	if Input.is_action_pressed("right") and can_move:
		velocity.x = speed * boost
	if Input.is_action_pressed("shift") and can_move:
		boost = 7
	else:
		boost = 1
	if Input.is_action_pressed("zoom_in") and can_move:
		zoom_velocity.x += 0.1 / boost
		zoom_velocity.y += 0.1 / boost
	if Input.is_action_pressed("zoom_out") and can_move:
		zoom_velocity.x -= 0.1 / boost
		zoom_velocity.y -= 0.1 / boost
	if Input.is_action_just_pressed("middle_mouse"):
		self.zoom = Vector2(0.73, 0.73)
		self.position = Vector2(528, 500)

	self.position.x += velocity.x
	self.position.y += velocity.y
	
	velocity.x = lerp(velocity.x, 0.0, 0.2)
	velocity.y = lerp(velocity.y, 0.0, 0.2)


	self.zoom.x = clamp(self.zoom.x + zoom_velocity.x, 0.1, 2)
	self.zoom.y = clamp(self.zoom.y + zoom_velocity.y, 0.1, 2)	
	
	zoom_velocity = Vector2(0, 0)

