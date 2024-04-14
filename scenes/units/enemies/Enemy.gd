class_name Enemy
extends InteractableThing

@export
var speed = 5.0
@export
var attack_damage := 1
@export
var attack_range := 1.5

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var aggro_zone: Area3D = $AggroZone
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var target: Unit
var stun_time: float = 0.0
var current_anim: String = ""
var is_dead := false
var dead_time := 0.0
var health := 5

func _physics_process(delta):
	if is_dead:
		dead_time += delta
		if dead_time > 2.0:
			queue_free()
		return
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
	if target.position.distance_to(self.position) < attack_range:
		attack()

func attack():
	target.attack_unit(attack_damage, self)
	anim_player.stop()
	animate("attack")
	stun_time = 1.5

func animate(animation: String):
	current_anim = animation

func move(delta):
	if stun_time > 0 || nav_agent.is_navigation_finished():
		return
	animate("walk")
	var target = nav_agent.get_next_path_position()
	var dir = global_position.direction_to(target)
	velocity = dir * speed
	if stun_time <= 0:
		move_and_slide()

func attack_enemy(damage: int):
	health -= damage
	if health <= 0:
		die()

func die():
	print("died")
	is_dead = true
	anim_player.stop()
	anim_player.play("die")

func get_spot() -> Vector3:
	return self.position
