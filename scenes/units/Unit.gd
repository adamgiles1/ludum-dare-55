class_name Unit
extends CharacterBody3D

var NO_OUTLINE: Material = load("res://assets/materials/Disabled.tres")
var HOVER: Material = load("res://assets/materials/Hovered.tres")
var SELECTED: Material = load("res://assets/materials/Selected.tres")

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
var spawned_from: AllySpawner

func _ready():
	set_outline(NO_OUTLINE);
	GameManager.unit_created()

func _physics_process(delta):
	stun_time_left -= delta
	if is_dead:
		time_dead += delta
		if death_limit < time_dead:
			GameManager.unit_died()
			queue_free()
		return
	velocity = Vector3.ZERO
	
	if not is_on_floor():
		velocity.y -= 100 * delta
		
	if !nav_agent.is_navigation_finished():
		calc_dir(delta)
	
	if stun_time_left <= 0:
		if velocity != Vector3.ZERO:
			var toward = velocity
			toward.y = 0
			var look_dir = transform.origin + toward
			look_at(look_dir, Vector3.UP)
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
	velocity = dir * speed * UI.get_unit_speed()

func send_command(location: Vector3, type: Globals.COMMAND, thing: InteractableThing, offset: Vector3):
	if type == Globals.COMMAND.INTERACT && thing != null && thing.is_in_group("attackable"):
		pass
	else:
		walk_to(location, true)
	handle_command(location, type, thing, offset)

func handle_command(location: Vector3, type: Globals.COMMAND, thing: InteractableThing, offset: Vector3):
	printerr("Unimplemented command for scene: " + self.name)

func walk_to(target: Vector3, with_audio: bool):
	if nav_agent == null:
		nav_agent = $NavigationAgent3D
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
	if GameManager.unit_sounds_per_second > 10:
		return
	var volume = -5 if GameManager.video_playing else 1.0
	GameManager.unit_sounds_per_second += 1
	var sounds: Node = get_node(sound_name)
	var num = randi_range(0, sounds.get_children().size() - 1)
	var audio: AudioStreamPlayer3D = sounds.get_child(num)
	audio.volume_db = volume
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
	
func dehover_selected():
	set_outline(SELECTED);
	
func set_outline(material: Material):
	%Outline.set_surface_override_material(0, material)

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

func set_spawned(spawner: AllySpawner):
	spawned_from = spawner
