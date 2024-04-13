class_name Unit
extends CharacterBody3D

var NO_OUTLINE: Color = Color(0, 0, 0, 0);
var HOVER: Color = Color(1, 1, 0, 1);
var SELECTED: Color = Color(1, 0, 0, 1);

@export var speed: float = 5
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var outline: MeshInstance3D = $%Outline


enum state {IDLE, WALKING, INTERACTING}
var interacting_with: Node = null

func _ready():
	set_outline(NO_OUTLINE);

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		GameManager.command_active_units(Vector3(10, 0, 10), Globals.COMMAND.MOVE)
	
	velocity = Vector3.ZERO
	
	if not is_on_floor():
		velocity.y -= 100 * delta
		
	if !nav_agent.is_navigation_finished():
		calc_dir(delta)
	
	move_and_slide()

func calc_dir(delta: float):
	var target = nav_agent.get_next_path_position()
	var dir = global_position.direction_to(target)
	velocity = dir * speed

func send_command(location: Vector3, type: Globals.COMMAND):
	print("receiving command: " + str(type))
	set_outline(NO_OUTLINE);
	walk_to(location)
	handle_command(location, type)

func handle_command(location: Vector3, type: Globals.COMMAND):
	printerr("Unimplemented command for scene: " + self.name)

func walk_to(target: Vector3):
	nav_agent.target_position = target
	play_sound("Walk")

func play_sound(sound_name: String):
	var sounds: Node = get_node(sound_name)
	var num = randi_range(0, sounds.get_children().size() - 1)
	var audio: AudioStreamPlayer3D = sounds.get_child(num)
	audio.play()

func select():
	set_outline(SELECTED);
	GameManager.set_active_unit(self)
	play_sound("Select")
	
func set_outline(color: Color):
	%Outline.set_instance_shader_parameter("color", color);
