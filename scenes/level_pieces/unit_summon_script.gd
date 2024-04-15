class_name AllySpawner
extends Node3D

@export
var unit_to_summon: PackedScene = load("res://scenes/units/BaseUnit.tscn")

@export
var max_summoned: int = 5
@export
var is_worker := false
@export
var is_unlock := false
@export
var team_id := -1
var is_enabled = true

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
	if is_unlock:
		Signals.TEAM_ELIMINATED.connect(handle_team_eliminated)
		print("locking for team: " + str(team_id))
		is_enabled = false
		visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_enabled:
		return
	timer -= delta
	if timer <= 0:
		spawn_unit()
		timer = time_between_summons * UI.get_spawner_time_mult()

func spawn_unit():
	if !GameManager.can_spawn_more_units() || !is_enabled:
		return
	var unit: Unit = unit_to_summon.instantiate()
	unit.position = self.position
	unit.set_spawned(self)
	if is_worker && has_last_command && is_instance_valid(unit) && command_thing != null:
		unit.send_command(command_vector, Globals.COMMAND.INTERACT, command_thing, Vector3.ZERO)
	
	get_tree().root.add_child(unit)

func set_last_command(vector: Vector3, thing: InteractableThing):
	command_vector = vector
	command_thing = thing
	has_last_command = true

func handle_team_eliminated(id: int):
	if team_id == id:
		is_enabled = true
		visible = true
