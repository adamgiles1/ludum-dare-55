extends InteractableThing
class_name BaseInteract

var NO_OUTLINE: Material = load("res://assets/materials/Disabled.tres")
var HOVER: Material = load("res://assets/materials/Hovered.tres")

@onready var outline: MeshInstance3D = $%Outline

func start_interacting():
	pass

func interact_with():
	UI.increase_wood(1)

func get_spot() -> Vector3:
	rotate_spot()
	return $InteractionPoints.get_child(next_spot).global_position

func hover():
	$%Outline.set_surface_material_override(0, HOVER)
	
func dehover():
	$%Outline.set_surface_material_override(0, NO_OUTLINE)
