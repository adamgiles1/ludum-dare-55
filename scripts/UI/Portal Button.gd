extends Button
class_name PortalButton

# Called when the node enters the scene tree for the first time.
func _ready():
	UI.register_portal_button(self)

