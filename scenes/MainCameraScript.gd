extends Camera3D

var speed = 5
var modifier = 5

var left_mouse_held: bool = false;

var hovers: Array[CollisionObject3D] = [] 
@onready var selection_area: SelectionArea = $"../SelectionArea"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	GameManager.hover(hovers)
		
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
	
func get_mouse_ray_intersect(mouse_position: Vector2):
	var worldspace = get_world_3d().direct_space_state
	var start = project_ray_origin(mouse_position)
	var end = project_position(mouse_position, 1000)
	return worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))

# Level 1
func _input(event):
	if !event is InputEventMouse:
		return
		
	if left_mouse_held:
		left_held_event(event)
	elif !UI.mouse_in_ui(event.position):
		regular_event(event)

# Level 2		
func left_held_event(event: InputEvent):
	if event is InputEventMouseMotion:
		drag_selection(event.position)
	elif event is InputEventMouseButton:
		if event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
			if UI.mouse_in_ui(event.position):
				cancel_selection()
			else:
				confirm_selection(event.position)
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_selection()
			
func regular_event(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			begin_selection(event)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			interact(event)
			
	elif event is InputEventMouseMotion:
		hover(event)

# Level 3
func hover(event: InputEvent): #Moving mouse without left button held
	var result = get_mouse_ray_intersect(event.position)
	if result.collider != null && result.collider.is_in_group("Unit") or result.collider.is_in_group("interactable"):
		hovers = [result.collider]
	else:
		hovers = []
		
func interact(event: InputEvent): # Right click
	var result = get_mouse_ray_intersect(event.position)	
	if result.collider.is_in_group("walkable"):
		GameManager.command_active_units(result.position, Globals.COMMAND.MOVE, null)
	if result.collider.is_in_group("interactable"):
		if result.collider.is_in_group("attackable"):
			GameManager.command_active_units(result.position, Globals.COMMAND.INTERACT, result.collider)
		else:
			GameManager.command_active_units(result.position, Globals.COMMAND.INTERACT, result.collider.get_parent())
	GameManager.spawn_hover_arrow(result.position)

func begin_selection(event: InputEvent): #Left mouse button down
	left_mouse_held = true
	var result = get_mouse_ray_intersect(event.position)
	selection_area.begin_drag(result.position)

func drag_selection(mouse_position: Vector2): #Moving mouse with left button held
	var result = get_mouse_ray_intersect(mouse_position)
	selection_area.update_drag(result.position)
	var units = selection_area.get_selection()
	hovers = []
	for unit in units:
		hovers.append(unit)
	# HEY THIS IS STUPID WHY
	
func cancel_selection(): #Right clicking or releasing left button in ui zone during drag selection
	left_mouse_held = false
	selection_area.cancel_drag()
	hovers = []
	
func confirm_selection(mouse_position: Vector2): #Releasing left button outside of ui zones during drag selection
	left_mouse_held = false
	var result = get_mouse_ray_intersect(mouse_position)
	if selection_area.match_position(result.position):
		if result.collider.is_in_group("Unit"):
			GameManager.select([result.collider])
		else:
			GameManager.select([])
	else:
		var units = selection_area.get_selection()
		GameManager.select(units)
	selection_area.cancel_drag()
	hovers = []
