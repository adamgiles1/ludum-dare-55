extends Node

var active_units: Array[Unit] = []

func command_active_units(location: Vector3, command: Globals.COMMAND, thing: InteractableThing):
	for unit in active_units:
		unit.send_command(location, command, thing)

func set_active_unit(unit: Unit):
	active_units = []
	active_units.append(unit)

func set_active_units(units: Array[Unit]):
	active_units = units

func deselect():
	active_units = []
