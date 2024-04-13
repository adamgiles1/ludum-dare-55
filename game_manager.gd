extends Node

@onready var hover_arrow_scen: PackedScene = preload("res://scenes/effects/ClickedArrow.tscn")

var active_units: Array[Unit] = []

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		Signals.SPAWN_UNITS.emit()

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

func spawn_hover_arrow(location: Vector3):
	Signals.HOVER_ARROW_SPAWNED.emit()
	var inst = hover_arrow_scen.instantiate()
	inst.position = location
	add_child(inst)
