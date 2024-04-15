extends Button
class_name BuildingButton

@export var building_type: UI.BuildingEnum
@export var building_scene: PackedScene
@export var base_wood_cost: int
@export var base_stone_cost: int
@export var base_metal_cost: int

var wood_cost: float:
	get:
		return base_wood_cost * purchases
var stone_cost: float:
	get:
		return base_stone_cost * purchases
var metal_cost: float:
	get:
		return base_metal_cost * purchases

var purchases: int = 1

func purchase():
	purchases += 1

# Called when the node enters the scene tree for the first time.
func _ready():
	UI.register_building_button(self)
	
func _process(delta):
	match building_type:
		UI.BuildingEnum.WORKER_SUMMONER:
			set_text("Worker Summoner (" + str(wood_cost) + ", 0, 0)")
