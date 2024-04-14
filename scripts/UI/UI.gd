extends Node

enum ResourceEnum { WOOD, STONE, METAL };

var wood_count: ResourceCount;
var stone_count: ResourceCount;
var metal_count: ResourceCount;

var ui_zones: Array[Control] = [];

func register_resource_count(resource_count: ResourceCount):
	match resource_count.resource:
		ResourceEnum.WOOD:
			wood_count = resource_count;
		ResourceEnum.STONE:
			stone_count = resource_count;
		ResourceEnum.METAL:
			metal_count = resource_count;
			
func reset():
	wood_count = null
	stone_count = null
	metal_count = null

func increase_wood(amount: int):
	wood_count.quantity += amount;
	
func increase_stone(amount: int):
	stone_count.quantity += amount;
	
func increase_metal(amount: int):
	metal_count.quantity += amount;
	
func spend_wood(amount: int):
	wood_count.quantity -= amount;
	
func spend_stone(amount: int):
	stone_count.quantity -= amount;
	
func spend_metal(amount: int):
	metal_count.quantity -= amount;
	
func check_wood(amount: int) -> bool:
	return wood_count.quantity >= amount;
	
func check_stone(amount: int) -> bool:
	return stone_count.quantity >= amount;
	
func check_metal(amount: int) -> bool:
	return metal_count.quantity >= amount;
	
func mouse_in_ui(mouse_position: Vector2) -> bool:
	for ui_zone in ui_zones:
		if Rect2(ui_zone.position, ui_zone.size).has_point(mouse_position):
			return true;
	return false;
