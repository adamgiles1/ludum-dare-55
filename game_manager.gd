extends Node

var active_units: Array[Unit] = []

func command_active_units(location: Vector3, command: Globals.COMMAND):
	print("sending command")
	for unit in active_units:
		unit.send_command(location, command)

func add_active_unit(unit: Unit):
	active_units.append(unit)
