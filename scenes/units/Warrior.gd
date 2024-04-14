extends Unit

@export
var ATTACK_RANGE := 2
const DAMAGE := 3

@onready var aggro_area: Area3D = $AggroArea
var time_till_next_attack := 0.0

func _ready():
	anim_overriden = true

func _process(delta):
	time_till_next_attack -= delta
	if stun_time_left > 0:
		return
	
	if current_state == STATE.INTERACTING:
		if interacting_with == null || !is_instance_valid(interacting_with) || interacting_with.is_dead:
			interacting_with = null
			find_new_target()
			return
		if close_enough_to_interact(interacting_with):
			if time_till_next_attack <= 0:
				attack(interacting_with)
				walk_to(self.position, false)
		else:
			walk_to(interacting_with.position, false)
	
	match current_state:
			STATE.WALKING:
				if !animator.is_playing():
					animator.play("walk")
			STATE.INTERACTING:
				pass
			STATE.IDLE:
				animator.stop()

func handle_command(location: Vector3, type: Globals.COMMAND, thing: InteractableThing):
	if thing != null && thing.is_in_group("attackable"):
		interacting_with = thing
		nav_agent.target_position = thing.get_spot()

func close_enough_to_interact(thing: InteractableThing) -> bool:
	if (self.position.distance_to(thing.position) < ATTACK_RANGE):
		return true
	return false

func attack(thing: Enemy):
	animator.stop()
	animator.play("interact")
	velocity = Vector3.ZERO
	thing.attack_enemy(DAMAGE, self)
	time_till_next_attack = 2
	stun_time_left = 1.0

func find_new_target():
	var enemies = aggro_area.get_overlapping_bodies()
	if enemies.size() > 0:
		interacting_with = enemies[randi_range(0, enemies.size() - 1)]
	else:
		current_state = STATE.IDLE
