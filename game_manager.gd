extends Node

var active_units: Array[Unit] = []

func command_active_units(location: Vector3, command: Globals.COMMAND):
	for unit in active_units:
		unit.send_command(location, command)

func set_active_unit(unit: Unit):
	active_units = []
	active_units.append(unit)

func deselect():
	active_units = []
