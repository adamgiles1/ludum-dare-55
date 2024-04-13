extends Camera3D

var mouse := Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
		GameManager.spawn_hover_arrow(result.position)
	if result.collider.is_in_group("interactable"):
		GameManager.command_active_units(result.position, Globals.COMMAND.INTERACT, result.collider.get_parent())
		

func left_click():
	var worldspace = get_world_3d().direct_space_state
	var start = project_ray_origin(mouse)
	var end = project_position(mouse, 1000)
	var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
	
	if result.collider.is_in_group("Unit"):
		result.collider.select()
	else:
		GameManager.deselect()

