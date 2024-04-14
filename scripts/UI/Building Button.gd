extends Button
class_name BuildingButton

@export var building: UI.BuildingEnum

# Called when the node enters the scene tree for the first time.
func _ready():
	UI.register_building_button(self)

