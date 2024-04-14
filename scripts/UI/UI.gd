extends Node

@onready var worker_summoner = load("res://scenes/level_pieces/base_unit_summoner.tscn")

var camera: MainCamera

enum ResourceEnum { WOOD, STONE, METAL };

var wood_count: ResourceCount;
var stone_count: ResourceCount;
var metal_count: ResourceCount;

var portal_button: PortalButton;

var ui_zones: Array[Control] = [];

var preview_wood_cost: int = 0
var preview_stone_cost: int = 0
var preview_metal_cost: int = 0
var preview_object: PackedScene = null
var preview_mode: bool = false

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

func register_portal_button(portal_button: PortalButton):
	self.portal_button = portal_button
	ui_zones.append(portal_button)
	portal_button.connect("pressed", buy_worker_portal)
		
func reset():
	wood_count = null
	stone_count = null
	metal_count = null
	portal_button = null
	camera = null
	ui_zones = []
	preview_mode = false
	
func mouse_in_ui(mouse_position: Vector2) -> bool:
	for ui_zone in ui_zones:
		if Rect2(ui_zone.position, ui_zone.size).has_point(mouse_position):
			return true;
	return false;
	
func buy_worker_portal():
	camera.begin_preview()
	preview_wood_cost = 5
	preview_object = worker_summoner
	preview_mode = true

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
	
func _process(delta: float):
	portal_button.disabled = wood_count.quantity < 5 or preview_mode

func increase_wood(amount: float):
	wood_count.quantity += amount
	
func increase_stone(amount: float):
	stone_count.quantity += amount
	
func increase_metal(amount: float):
	metal_count.quantity += amount
