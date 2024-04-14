extends Node

@onready var worker_summoner = load("res://scenes/level_pieces/base_unit_summoner.tscn")

var camera: MainCamera

enum ResourceEnum { WOOD, STONE, METAL };
enum BuildingEnum { WORKER_SUMMONER };
enum UpgradeEnum { DOUBLE_MOVEMENT };

var wood_count: ResourceCount;
var stone_count: ResourceCount;
var metal_count: ResourceCount;

var worker_summoner_button: BuildingButton;

var double_movement_button: UpgradeButton;

var purchased_upgrades: Array[UpgradeEnum] = []

#To prevent clicking on the game when touching buttons
var ui_zones: Array[Control] = [];

#Temporary values associated with a building when we're previewing it and trying to place it
var preview_wood_cost: int = 0
var preview_stone_cost: int = 0
var preview_metal_cost: int = 0
var preview_object: PackedScene = null
var preview_mode: bool = false

#Registration
func register_camera(camera: MainCamera):
	self.camera = camera

func register_resource_count(resource_count: ResourceCount):
	match resource_count.resource:
		ResourceEnum.WOOD:
			wood_count = resource_count;
		ResourceEnum.STONE:
			stone_count = resource_count;
		ResourceEnum.METAL:
			metal_count = resource_count;

func register_building_button(building_button: BuildingButton):
	ui_zones.append(building_button)
	match building_button.building:
		BuildingEnum.WORKER_SUMMONER:
			worker_summoner_button = building_button
			worker_summoner_button.connect("pressed", buy_worker_summoner)
			
func register_upgrade_button(upgrade_button: UpgradeButton):
	ui_zones.append(upgrade_button)
	match upgrade_button.upgrade:
		UpgradeEnum.DOUBLE_MOVEMENT:
			double_movement_button = upgrade_button
			double_movement_button.connect("pressed", buy_double_movement)
			
			#Commenting this out for now for testing, should be made visible via conquering a base
			#double_movement_button.visible = false

#Utility		
func reset():
	wood_count = null
	stone_count = null
	metal_count = null

	worker_summoner_button = null

	double_movement_button = null

	camera = null
	ui_zones = []
	preview_mode = false
	purchased_upgrades = []
	
func mouse_in_ui(mouse_position: Vector2) -> bool:
	for ui_zone in ui_zones:
		if ui_zone.visible and Rect2(ui_zone.position, ui_zone.size).has_point(mouse_position):
			return true;
	return false;

#Buy Buildings	
func buy_worker_summoner():
	camera.begin_preview()
	preview_wood_cost = 5
	preview_object = worker_summoner
	preview_mode = true

#Buy Upgrades
func buy_double_movement():
	wood_count.quantity -= 5
	purchased_upgrades.append(UpgradeEnum.DOUBLE_MOVEMENT)
	double_movement_button.visible = false

#Building Preview
func confirm_preview(position: Vector3):
	wood_count.quantity -= preview_wood_cost
	stone_count.quantity -= preview_stone_cost
	metal_count.quantity -= preview_metal_cost
	var build = preview_object.instantiate()
	camera.get_parent().add_child(build)
	build.global_position = position
	cancel_preview()

func cancel_preview():
	preview_object = null
	preview_wood_cost = 0
	preview_stone_cost = 0
	preview_metal_cost = 0
	preview_mode = false

#UI Control	
func _process(delta: float):
	if worker_summoner_button:
		worker_summoner_button.disabled = wood_count.quantity < 5 or preview_mode #Store upgrade costs on the button inspector maybe?
	
	if double_movement_button:
		double_movement_button.disabled = wood_count.quantity < 5 or preview_mode

#Gather Resources
func increase_wood(amount: float):
	wood_count.quantity += amount
	
func increase_stone(amount: float):
	stone_count.quantity += amount
	
func increase_metal(amount: float):
	metal_count.quantity += amount

#Output Upgraded Values
func get_unit_speed():
	return 2 if UpgradeEnum.DOUBLE_MOVEMENT in purchased_upgrades else 1 
