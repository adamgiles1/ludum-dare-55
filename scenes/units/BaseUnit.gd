extends Unit


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var time_till_next_resource: float = 3

func _process(delta):
	if current_state == STATE.INTERACTING:
		time_till_next_resource -= delta
		if time_till_next_resource <= 0:
			interacting_with.interact_with()
			time_till_next_resource = 3

func handle_command(location: Vector3, type: Globals.COMMAND, thing: InteractableThing):
	# todo should check if this is thing we can interact with first
	interacting_with = thing

func close_enough_to_interact(thing: InteractableThing) -> bool:
	if (self.position.distance_to(thing.position) < 1.5):
		return true
	return false
