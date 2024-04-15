extends Button
class_name UpgradeButton

@export var upgrade: UI.UpgradeEnum
@export var wood_cost: float
@export var stone_cost: float
@export var metal_cost: float

# Called when the node enters the scene tree for the first time.
func _ready():
	UI.register_upgrade_button(self)

func _process(delta: float):
	match upgrade:
		UI.UpgradeEnum.DOUBLE_MOVEMENT:
			set_text("Double Movement (" + str(wood_cost) + ", 0, 0)")

