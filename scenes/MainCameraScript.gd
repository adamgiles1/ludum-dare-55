extends Camera3D
class_name MainCamera

enum Mode { NEUTRAL, SELECTION_AREA, PLACEMENT_PREVIEW }

var speed = 20
var modifier = 5

var mode: Mode = Mode.NEUTRAL
#var left_mouse_held: bool = false;

var hovers: Array[CollisionObject3D] = [] 
@onready var selection_area: SelectionArea = $"../SelectionArea"
@onready var placement_preview: PlacementPreview = $"../PlacementPreview"

var pentagram_lerp_time = 0.0
var pentagram_start: Vector3
const pentagram_end: Vector3 = Vector3(-10, 130, 0)
const pentagram_rot_end: Vector3 = Vector3(-1.57, 1.57, 0)
var pentagram_rot_start: Vector3
var pentagram_time = false
const time_till_pentagram = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	UI.register_camera(self)
	Signals.GAME_WON.connect(send_camera_to_pentagram)

func _process(delta):
	if pentagram_time:
		pentagram_lerp_time += delta
		if pentagram_lerp_time > time_till_pentagram:
			pentagram_lerp_time = time_till_pentagram
		position = lerp(pentagram_start, pentagram_end, pentagram_lerp_time / time_till_pentagram)
		rotation = lerp(pentagram_rot_start, pentagram_rot_end, pentagram_lerp_time / time_till_pentagram)
	
	GameManager.hover(hovers)
		
	var vel = Vector3.ZERO
	if Input.is_action_pressed("camera_down") && position.x > -200:
		vel.x = -1
	if Input.is_action_pressed("camera_up") && position.x < 200:
		vel.x = 1
	if Input.is_action_pressed("camera_left") && position.z > -200:
		vel.z = -1
	if Input.is_action_pressed("camera_right") && position.z < 200:
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
	
	match mode:
		Mode.PLACEMENT_PREVIEW:
			preview_event(event)
		Mode.SELECTION_AREA:	
			left_held_event(event)
		Mode.NEUTRAL:
			regular_event(event)

# Level 2
func preview_event(event: InputEvent):
	if event is InputEventMouseMotion:
		drag_preview(event.position)
	elif event is InputEventMouseButton:
		if event.is_released() and event.button_index == MOUSE_BUTTON_LEFT and !UI.mouse_in_ui(event.position):
			confirm_preview()
		elif event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_preview()
			
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
	if UI.mouse_in_ui(event.position):
		return
		
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
	if !result.has("collider"):
		return
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
	mode = Mode.SELECTION_AREA
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
	mode = Mode.NEUTRAL
	selection_area.end_drag()
	hovers = []
	
func confirm_selection(mouse_position: Vector2): #Releasing left button outside of ui zones during drag selection
	mode = Mode.NEUTRAL
	var result = get_mouse_ray_intersect(mouse_position)
	if selection_area.match_position(result.position):
		if result.collider.is_in_group("Unit"):
			GameManager.select([result.collider])
		else:
			GameManager.select([])
	else:
		var units = selection_area.get_selection()
		GameManager.select(units)
	selection_area.end_drag()
	hovers = []

func begin_preview():
	mode = Mode.PLACEMENT_PREVIEW
	
func drag_preview(mouse_position: Vector2):
	var result = get_mouse_ray_intersect(mouse_position)
	placement_preview.update_drag(result.position)

func cancel_preview():
	mode = Mode.NEUTRAL
	UI.cancel_preview()
	placement_preview.end_drag()

func confirm_preview():
	if placement_preview.confirm_position():
		UI.confirm_preview(placement_preview.spawn_position())
		mode = Mode.NEUTRAL
		placement_preview.end_drag()

func send_camera_to_pentagram():
	pentagram_start = self.position
	pentagram_rot_start = self.rotation
	pentagram_time = true
	print("rot start: " + str(pentagram_rot_start))
