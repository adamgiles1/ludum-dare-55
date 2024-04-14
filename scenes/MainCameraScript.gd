extends Camera3D

var mouse := Vector2()

var speed = 5
var modifier = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var vel = Vector3.ZERO
	if Input.is_action_pressed("camera_down"):
		vel.x = -1
	if Input.is_action_pressed("camera_up"):
		vel.x = 1
	if Input.is_action_pressed("camera_left"):
		vel.z = -1
	if Input.is_action_pressed("camera_right"):
		vel.z = 1
	var mod = 1
	if Input.is_action_pressed("camera_fast"):
		mod = modifier
	position += vel * delta * speed * mod

func _input(event):
	if event is InputEventMouse:
		mouse = event.position
	if event is InputEventMouseButton and event.pressed and !UI.mouse_in_ui(mouse):
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right_click()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			left_click()

func right_click():
	var worldspace = get_world_3d().direct_space_state
	var start = project_ray_origin(mouse)
	var end = project_position(mouse, 1000)
	var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
	
	if result.collider.is_in_group("walkable"):
		GameManager.command_active_units(result.position, Globals.COMMAND.MOVE, null)
	if result.collider.is_in_group("interactable"):
		GameManager.command_active_units(result.position, Globals.COMMAND.INTERACT, result.collider.get_parent())
		
	GameManager.spawn_hover_arrow(result.position)

func left_click():
	var worldspace = get_world_3d().direct_space_state
	var start = project_ray_origin(mouse)
	var end = project_position(mouse, 1000)
	var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
	
	if result.collider.is_in_group("Unit"):
		result.collider.select()
	else:
		GameManager.deselect()

