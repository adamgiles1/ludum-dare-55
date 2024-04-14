extends Node

@onready var hover_arrow_scen: PackedScene = preload("res://scenes/effects/ClickedArrow.tscn")

var active_units: Array[Unit] = []
var active_hovers: Array = [] #TODO HELP

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		Signals.SPAWN_UNITS.emit()

func command_active_units(location: Vector3, command: Globals.COMMAND, thing: InteractableThing):
	for unit in active_units:
		if is_instance_valid(unit):
			unit.send_command(location, command, thing)

func select(units: Array[Unit]):
	for unit in active_units:
		if is_instance_valid(unit):
			unit.deselect()
	active_units = units
	for unit in units:
		unit.select()

func hover(hovers: Array): #TODO type hint real
	for hover in active_hovers:
		if hover.is_in_group("Unit"):
			hover.dehover()
	active_hovers = hovers
	for hover in hovers:
		if hover.is_in_group("Unit"):
			hover.hover()

func spawn_hover_arrow(location: Vector3):
	Signals.HOVER_ARROW_SPAWNED.emit()
	var inst = hover_arrow_scen.instantiate()
	inst.position = location
	add_child(inst)
