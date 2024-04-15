extends Node

var camera: MainCamera

enum ResourceEnum { WOOD, STONE, METAL, UNIT_CAP };
enum BuildingEnum { WORKER_SUMMONER };
enum UpgradeEnum { DOUBLE_MOVEMENT, SERPENT_UPGRADE, WORKER_UPGRADE };

var wood_count: ResourceCount;
var stone_count: ResourceCount;
var metal_count: ResourceCount;
var unit_cap_count: ResourceCount;

var worker_summoner_button: BuildingButton;

var double_movement_button: UpgradeButton;
var serpent_upgrade_button: UpgradeButton;
var worker_upgrade_button: UpgradeButton;
var spawner_upgrade_button: UpgradeButton;

var purchased_upgrades: Array[UpgradeEnum] = []

#To prevent clicking on the game when touching buttons
var ui_zones: Array[Control] = [];

#Temporary values associated with a building when we're previewing it and trying to place it
var previewed_button: BuildingButton
var preview_mode: bool = false

func _ready():
	Signals.TEAM_ELIMINATED.connect(handle_team_eliminated)

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
		ResourceEnum.UNIT_CAP:
			unit_cap_count = resource_count;

func register_building_button(building_button: BuildingButton):
	ui_zones.append(building_button)
	match building_button.building_type:
		BuildingEnum.WORKER_SUMMONER:
			worker_summoner_button = building_button
			worker_summoner_button.connect("pressed", buy_worker_summoner)
			
func register_upgrade_button(upgrade_button: UpgradeButton):
	ui_zones.append(upgrade_button)
	match upgrade_button.upgrade:
		UpgradeEnum.DOUBLE_MOVEMENT:
			double_movement_button = upgrade_button
			double_movement_button.connect("pressed", buy_double_movement)
		UpgradeEnum.SERPENT_UPGRADE:
			serpent_upgrade_button = upgrade_button
			serpent_upgrade_button.connect("pressed", buy_serpent_upgrade)
			
	upgrade_button.visible = false

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
	previewed_button = worker_summoner_button
	preview_mode = true

#Buy Upgrades
func buy_double_movement():
	buy_upgrade(double_movement_button)

func buy_upgrade(upgrade_button: UpgradeButton):
	wood_count.quantity -= upgrade_button.wood_cost
	stone_count.quantity -= upgrade_button.stone_cost
	metal_count.quantity -= upgrade_button.metal_cost
	purchased_upgrades.append(upgrade_button.upgrade)
	upgrade_button.visible = false

func buy_serpent_upgrade():
	print("buying serpent upgrade hiss")
	wood_count.quantity -= 50
	purchased_upgrades.append(UpgradeEnum.SERPENT_UPGRADE)
	serpent_upgrade_button.visible = false

#Building Preview
func confirm_preview(position: Vector3):
	wood_count.quantity -= previewed_button.wood_cost
	stone_count.quantity -= previewed_button.stone_cost
	metal_count.quantity -= previewed_button.metal_cost
	var build = previewed_button.building_scene.instantiate()
	camera.get_parent().add_child(build)
	build.global_position = position
	previewed_button.purchase()
	cancel_preview()

func cancel_preview():
	previewed_button = null
	preview_mode = false

#UI Control	
func _process(delta: float):
	if worker_summoner_button:
		worker_summoner_button.disabled = wood_count.quantity < 5 or preview_mode #Store upgrade costs on the button inspector maybe?
	
	if double_movement_button:
		double_movement_button.disabled = wood_count.quantity < 5 or preview_mode
	
	if serpent_upgrade_button:
		serpent_upgrade_button.disabled = wood_count.quantity < 50 or preview_mode
	
	if worker_upgrade_button:
		worker_upgrade_button.disabled = stone_count.quantity < 50 or preview_mode
	for button in [worker_summoner_button, double_movement_button]:
		if button:
			button.disabled = wood_count.quantity < button.wood_cost or stone_count.quantity < button.stone_cost or metal_count.quantity < button.metal_cost or preview_mode

#Gather Resources
func increase_wood(amount: float):
	wood_count.quantity += amount
	
func increase_stone(amount: float):
	stone_count.quantity += amount
	
func increase_metal(amount: float):
	metal_count.quantity += amount

func update_unit_count(units: int):
	unit_cap_count.capped_resource = units

#Output Upgraded Values
func get_unit_speed():
	return 2 if UpgradeEnum.DOUBLE_MOVEMENT in purchased_upgrades else 1 

func get_serpent_damage_mult():
	return 2 if UpgradeEnum.SERPENT_UPGRADE in purchased_upgrades else 1

func handle_team_eliminated(team: int):
	match team:
		1:
			double_movement_button.visible = true
		2:
			serpent_upgrade_button.visible = true
		_:
			printerr("Unexpected team eliminated")
			
