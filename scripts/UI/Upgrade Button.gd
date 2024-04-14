extends Button
class_name UpgradeButton

@export var upgrade: UI.UpgradeEnum

# Called when the node enters the scene tree for the first time.
func _ready():
	UI.register_upgrade_button(self)

