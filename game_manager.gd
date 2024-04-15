extends Node

@onready var hover_arrow_scen: PackedScene = preload("res://scenes/effects/ClickedArrow.tscn")
@onready var intro_video: PackedScene = preload("res://scenes/UI/FirstVideo.tscn")
@onready var one_camp_vid: PackedScene = preload("res://scenes/UI/1camp.tscn")
@onready var two_camp_vid: PackedScene = preload("res://scenes/UI/2camp.tscn")
@onready var three_camp_vid: PackedScene = preload("res://scenes/UI/3camp.tscn")
@onready var final_vid: PackedScene = preload("res://scenes/UI/FinalVid.tscn")

var play_videos = true

var active_units: Array[Unit] = []
var active_hovers: Array[CollisionObject3D] = []

var total_units: int = 0
var unit_cap = 50

var unit_sounds_per_second = 0
var time_till_sound_wipe = 1

var camps_down := 0

var summoners: Array[EnemySpawner] = []

var video_playing := false

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("1"):
		Signals.GAME_WON.emit()
		pass
	
	if Input.is_action_just_pressed("video_skip"):
		Signals.VIDEO_IS_PLAYING.emit()
	
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
		if is_instance_valid(hover):
			if hover is Unit:
				if hover in active_units:
					hover.dehover_selected()
				else:
					hover.dehover()
			elif hover.get_parent() is BaseInteract:
				hover.get_parent().dehover()
	active_hovers = hovers
	for hover in hovers:
		if is_instance_valid(hover):
			if hover is Unit:
				hover.hover()
			elif hover.get_parent() is BaseInteract:
				hover.get_parent().hover()

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
		camps_down += 1
		play_camp_video()
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

func play_video(video: PackedScene):
	Signals.VIDEO_IS_PLAYING.emit()
	if !play_videos:
		return
	var t = video.instantiate()
	get_tree().root.add_child(t)

func play_camp_video():
	match camps_down:
		1:
			play_video(one_camp_vid)
		2:
			play_video(two_camp_vid)
		3:
			play_video(three_camp_vid)
		_:
			print("no video for this camp")

func play_final_video():
	play_video(final_vid)

func play_first_video():
	play_video(intro_video)
