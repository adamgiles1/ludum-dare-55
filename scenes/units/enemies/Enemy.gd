class_name Enemy
extends CharacterBody3D

@export
var speed = 5.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var aggro_zone: Area3D = $AggroZone
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var target: Unit
var stun_time: float = 0.0
var current_anim: String = ""

func _physics_process(delta):
	stun_time -= delta
	if stun_time > 0:
		return
	
	if target == null:
		detect_enemy()
	else:
		attempt_attack()
	
	move(delta)
	
	if target != null && target.is_dead:
		target = null
	
	if !anim_player.is_playing() && current_anim != "":
		anim_player.play(current_anim)

func detect_enemy():
	var targets = aggro_zone.get_overlapping_bodies()
	if targets.size() > 0:
		target = targets[0]

func attempt_attack():
	nav_agent.target_position = target.position
	print(nav_agent.target_position)
	if target.position.distance_to(self.position) < 1.0:
		attack()

func attack():
	anim_player.stop()
	animate("attack")
	stun_time = 1.5

func animate(animation: String):
	current_anim = animation

func move(delta):
	if stun_time > 0:
		return
	animate("walk")
	var target = nav_agent.get_next_path_position()
	var dir = global_position.direction_to(target)
	velocity = dir * speed
	if stun_time <= 0:
		move_and_slide()
