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
var spawned_from: EnemySpawner
var patrol_cd: float = randf_range(4, 8)

func _ready():
	var pos = get_patrol_position()
	nav_agent.target_position = pos

func _physics_process(delta):
	patrol_cd -= delta
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
	if current_anim == "" && velocity == Vector3.ZERO:
		anim_player.stop()

func detect_enemy():
	var targets = aggro_zone.get_overlapping_bodies()
	if targets.size() > 0:
		target = targets[0]
	else:
		if nav_agent.navigation_finished && patrol_cd <= 0:
			patrol_cd = randf_range(2, 5)
			nav_agent.target_position = get_patrol_position()

func attempt_attack():
	nav_agent.target_position = target.position
	if target.position.distance_to(self.position) < attack_range:
		attack()

func attack():
	target.attack_unit(attack_damage * UI.get_serpent_damage_mult(), self)
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
		var toward = velocity
		toward.y = 0
		var look_dir = transform.origin + toward
		look_at(look_dir, Vector3.UP)
		move_and_slide()

func attack_enemy(damage: int, from: Unit):
	health -= damage
	if health <= 0:
		die()
	if !is_instance_valid(target) || target == null:
		target = from
func die():
	is_dead = true
	anim_player.stop()
	anim_player.play("die")
	spawned_from.unit_died(self)

func get_spot() -> Vector3:
	return self.position

func set_spawner(spawner: EnemySpawner):
	spawned_from = spawner

func get_patrol_position() -> Vector3:
	if !is_instance_valid(spawned_from):
		return Vector3.ZERO
	var pos = spawned_from.position
	pos.x += randf_range(-4, 4)
	pos.z += randf_range(-4, 4)
	return pos
