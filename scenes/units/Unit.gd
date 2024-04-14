class_name Unit
extends CharacterBody3D

var NO_OUTLINE: Color = Color(0, 0, 0, 0);
var HOVER: Color = Color(1, 1, 0, 1);
var SELECTED: Color = Color(1, 0, 0, 1);

@export var speed: float = 5
@export var health: int = 1

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var outline: MeshInstance3D = $%Outline


enum STATE {IDLE, WALKING, INTERACTING, DYING}
var current_state: STATE
var interacting_with: InteractableThing = null
var is_dead: bool = false
var time_dead: float = 0.0
var death_limit: float = 1.0
var anim_overriden = false
var stun_time_left: float = 0.0

func _ready():
	set_outline(NO_OUTLINE);

func _physics_process(delta):
	stun_time_left -= delta
	if is_dead:
		time_dead += delta
		if death_limit < time_dead:
			queue_free()
		return
	velocity = Vector3.ZERO
	
	if not is_on_floor():
		velocity.y -= 100 * delta
		
	if !nav_agent.is_navigation_finished():
		calc_dir(delta)
	
	if stun_time_left <= 0:
		move_and_slide()
	
	if current_state == STATE.WALKING && nav_agent.is_navigation_finished():
		current_state = STATE.IDLE
	
	if current_state != STATE.INTERACTING && interacting_with != null && close_enough_to_interact(interacting_with):
		start_interaction(interacting_with)
	
	if !anim_overriden:
		match current_state:
			STATE.WALKING:
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
	set_outline(NO_OUTLINE);
	walk_to(location, true)
	handle_command(location, type, thing)

func handle_command(location: Vector3, type: Globals.COMMAND, thing: InteractableThing):
	printerr("Unimplemented command for scene: " + self.name)

func walk_to(target: Vector3, with_audio: bool):
	nav_agent.target_position = target
	current_state = STATE.WALKING
	if with_audio:
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
	#audio.pitch_scale = 1 + randf_range(-.2, .2)
	audio.play()

func select():
	set_outline(SELECTED);
	play_sound("Select")

func deselect():
	set_outline(NO_OUTLINE);

func hover():
	set_outline(HOVER);

func dehover():
	set_outline(NO_OUTLINE);
	
func set_outline(color: Color):
	%Outline.set_instance_shader_parameter("color", color);

func attack_unit(damage: int, from: InteractableThing):
	health -= damage
	if health <= 0:
		die()
	if interacting_with == null:
		walk_to(from.position, false)
		interacting_with = from

func die():
	current_state = STATE.DYING
	is_dead = true
	animator.stop()
	animator.play("die")
	play_sound("Die")
