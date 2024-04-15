extends InteractableThing
class_name BaseInteract

var NO_OUTLINE: Material = load("res://assets/materials/Disabled.tres")
var HOVER: Material = load("res://assets/materials/Hovered.tres")

@onready var outline: MeshInstance3D = $%Outline

enum RESOURCE {WOOD, ROCK, MAMMAL}
@export var resource: RESOURCE

func _ready():
	$%Outline.set_surface_override_material(0, NO_OUTLINE)

func start_interacting():
	pass

func interact_with():
	match resource:
		RESOURCE.WOOD:
			UI.increase_wood(1)
		RESOURCE.ROCK:
			UI.increase_stone(1)
		RESOURCE.MAMMAL:
			UI.increase_metal(1)

func get_spot() -> Vector3:
	rotate_spot()
	return $InteractionPoints.get_child(next_spot).global_position

func hover():
	$%Outline.set_surface_override_material(0, HOVER)
	
func dehover():
	$%Outline.set_surface_override_material(0, NO_OUTLINE)
