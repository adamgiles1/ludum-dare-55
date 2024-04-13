extends Unit


const JUMP_VELOCITY = 4.5

func handle_command(location: Vector3, type: Globals.COMMAND, thing: InteractableThing):
	# todo should check if this is thing we can interact with first
	if thing != null && thing.is_in_group("attackable"):
		interacting_with = thing
		nav_agent.target_position = thing.get_spot()

func close_enough_to_interact(thing: InteractableThing) -> bool:
	if (self.position.distance_to(thing.position) < 1.5):
		return true
	return false
