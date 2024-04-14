class_name EnemySpawner
extends Node3D

@export var team_id: int = 1
@export var summon_type: PackedScene = preload("res://scenes/units/enemies/BaseEnemy.tscn")
@export var max_units: int = 3

var timer: float = 1
const time_between_summons := 15
var disable = false

var units: Array[Enemy] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.register_enemy_summoner(self, team_id)
	Signals.TEAM_ELIMINATED.connect(handle_spawn_disabled)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if disable:
		return
	
	timer -= delta
	if timer <= 0:
		spawn()
		timer = time_between_summons

func spawn():
	if units.size() > max_units:
		return
	var spawned = summon_type.instantiate()
	spawned.position = self.position
	units.append(spawned)
	spawned.set_spawner(self)
	get_tree().root.add_child(spawned)

func unit_died(unit: Enemy):
	units.erase(unit)
	if units.size() == 0:
		GameManager.summoner_empty(team_id)

func handle_spawn_disabled(id: int):
	if id == self.team_id:
		print("disabled")
		disable = true
