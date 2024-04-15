extends Node

@onready var hover_arrow_scen: PackedScene = preload("res://scenes/effects/ClickedArrow.tscn")

var active_units: Array[Unit] = []
var active_hovers: Array[CollisionObject3D] = []

var total_units: int = 0
var unit_cap = 50

var unit_sounds_per_second = 0
var time_till_sound_wipe = 1

var summoners: Array[EnemySpawner] = []

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		Signals.SPAWN_UNITS.emit()
	
	if Input.is_action_just_pressed("ui_cancel"):
		Signals.GAME_WON.emit()
	
	time_till_sound_wipe -= delta
	if time_till_sound_wipe <= 0:
		time_till_sound_wipe = 1
		unit_sounds_per_second = 0

func command_active_units(location: Vector3, command: Globals.COMMAND, thing: InteractableThing):
	var offset_locations = get_offsets(active_units.size())
	var offset_idx = 0
	for unit in active_units:
		if is_instance_valid(unit):
			var offset = Vector3.ZERO
			if active_units.size() > 1:
				offset = offset_locations[offset_idx]
				offset_idx += 1
				if offset_idx >= offset_locations.size():
					offset_idx = 0
			unit.send_command(location, command, thing, offset)

func select(units: Array[Unit]):
	for unit in active_units:
		if is_instance_valid(unit):
			unit.deselect()
	active_units = units
	for unit in units:
		unit.select()

func hover(hovers: Array[CollisionObject3D]):
	for hover in active_hovers:
		if is_instance_valid(hover) && hover.is_in_group("Unit"):
			hover.dehover()
	active_hovers = hovers
	for hover in hovers:
		if is_instance_valid(hover) && hover.is_in_group("Unit"):
			hover.hover()

func spawn_hover_arrow(location: Vector3):
	Signals.HOVER_ARROW_SPAWNED.emit()
	var inst = hover_arrow_scen.instantiate()
	inst.position = location
	add_child(inst)

func register_enemy_summoner(spawner: EnemySpawner, team_id: int):
	summoners.append(spawner)

func summoner_empty(team_id: int):
	var all_out = true
	for summoner in summoners:
		if summoner.team_id == team_id && summoner.units.size() > 0:
			all_out = false
	if all_out:
		Signals.TEAM_ELIMINATED.emit(team_id)
		check_if_game_over()

func check_if_game_over():
	for summoner in summoners:
		if summoner.units.size() != 0:
			return
	Signals.GAME_WON.emit()
	print("yay")

func get_offsets(count: int) -> Array[Vector3]:
	var mult := 2
	var grid_size: float = 10
	for i in 10:
		if i * i >= count:
			grid_size = i
			break
	
	var minus = grid_size / 2
	var offsets: Array[Vector3] = []
	for x: float in grid_size:
		for z: float in grid_size:
			offsets.append(Vector3((z - minus) * mult, 0, (x - minus) * mult))
	return offsets

func unit_created():
	total_units += 1
	UI.update_unit_count(total_units)

func unit_died():
	total_units -= 1
	UI.update_unit_count(total_units)

func can_spawn_more_units() -> bool:
	return total_units <= unit_cap
