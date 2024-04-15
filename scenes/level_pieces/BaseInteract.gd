extends InteractableThing

func start_interacting():
	pass

func interact_with():
	UI.increase_wood(1)

func get_spot() -> Vector3:
	rotate_spot()
	return $InteractionPoints.get_child(next_spot).global_position
