class_name AllySpawner
extends Node3D

@export
var unit_to_summon: PackedScene = load("res://scenes/units/BaseUnit.tscn")

@export
var max_summoned: int = 5
@export
var is_worker := false

var timer: float = 1
const time_between_summons := 15

var units: Array[Unit] = []

var has_last_command := false
var command_vector: Vector3
var command_thing: InteractableThing

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.SPAWN_UNITS.connect(spawn_unit)
	global_position.y = 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer -= delta
	if timer <= 0:
		spawn_unit()
		timer = time_between_summons

func spawn_unit():
	var unit: Unit = unit_to_summon.instantiate()
	unit.position = self.position
	unit.set_spawned(self)
	if is_worker && has_last_command:
		unit.send_command(command_vector, Globals.COMMAND.INTERACT, command_thing, Vector3.ZERO)
	
	get_tree().root.add_child(unit)

func set_last_command(vector: Vector3, thing: InteractableThing):
	command_vector = vector
	command_thing = thing
	has_last_command = true
