extends Unit


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var time_till_next_resource: float = 3

func _process(delta):
	if current_state == STATE.INTERACTING:
		time_till_next_resource -= delta
		if time_till_next_resource <= 0:
			if is_instance_valid(interacting_with):
				interacting_with.interact_with()
			time_till_next_resource = 3

func handle_command(location: Vector3, type: Globals.COMMAND, thing: InteractableThing, offset: Vector3):
	# todo should check if this is thing we can interact with first
	interacting_with = thing
	if thing != null:
		nav_agent.target_position = thing.get_spot()
		if Globals.COMMAND.INTERACT == type:
			spawned_from.set_last_command(location, thing)

func close_enough_to_interact(thing: InteractableThing) -> bool:
	if (self.position.distance_to(thing.position) < 3):
		return true
	return false
