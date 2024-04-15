extends Button
class_name UpgradeButton

@export var upgrade: UI.UpgradeEnum
@export var wood_cost: float
@export var stone_cost: float
@export var metal_cost: float

# Called when the node enters the scene tree for the first time.
func _ready():
	UI.register_upgrade_button(self)
	match upgrade:
		UI.UpgradeEnum.DOUBLE_MOVEMENT:
			set_text("Double Movement " + get_cost())
		UI.UpgradeEnum.SERPENT:
			set_text("Double Serpent Damage " + get_cost())
		UI.UpgradeEnum.WORKER:
			set_text("Workers Faster Gather " + get_cost())
		UI.UpgradeEnum.SPAWNER:
			set_text("Summoners Faster " + get_cost())

func _process(delta: float):
	pass

func get_cost() -> String:
	return "(" + str(wood_cost) + ", " + str(stone_cost) + ", " + str(metal_cost) + ")"
