class_name Unit
extends CharacterBody3D


@export var speed: float = 5
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animator: AnimationPlayer = $AnimationPlayer


enum STATE {IDLE, WALKING, INTERACTING}
var current_state: STATE
var interacting_with: InteractableThing = null

func _ready():
	pass

func _physics_process(delta):
	velocity = Vector3.ZERO
	
	if not is_on_floor():
		velocity.y -= 100 * delta
		
	if !nav_agent.is_navigation_finished():
		calc_dir(delta)
	
	move_and_slide()
	
	if current_state != STATE.INTERACTING && interacting_with != null && close_enough_to_interact(interacting_with):
		start_interaction(interacting_with)
	
	match current_state:
		STATE.WALKING:
			print("walking")
			if !animator.is_playing():
				animator.play("walk")
		STATE.INTERACTING:
			animator.play("interact")
		STATE.IDLE:
			animator.stop()

func calc_dir(delta: float):
	var target = nav_agent.get_next_path_position()
	var dir = global_position.direction_to(target)
	velocity = dir * speed

func send_command(location: Vector3, type: Globals.COMMAND, thing: InteractableThing):
	print("receiving command: " + str(Globals.COMMAND.keys()[type]))
	walk_to(location)
	handle_command(location, type, thing)

func handle_command(location: Vector3, type: Globals.COMMAND, thing: InteractableThing):
	printerr("Unimplemented command for scene: " + self.name)

func walk_to(target: Vector3):
	nav_agent.target_position = target
	current_state = STATE.WALKING
	play_sound("Walk")

func close_enough_to_interact(thing: InteractableThing) -> bool:
	printerr("Unimplemented interact for scene: " + self.name)
	return false

func start_interaction(thing: InteractableThing):
	thing.start_interacting()
	current_state = STATE.INTERACTING

func play_sound(sound_name: String):
	var sounds: Node = get_node(sound_name)
	var num = randi_range(0, sounds.get_children().size() - 1)
	var audio: AudioStreamPlayer3D = sounds.get_child(num)
	audio.play()

func select():
	GameManager.set_active_unit(self)
	play_sound("Select")
