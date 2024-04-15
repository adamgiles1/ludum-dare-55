extends MeshInstance3D
class_name PlacementPreview

@onready var collision_area: Area3D = $"Collision Area"
@onready var link_area: Area3D = $"Link Area"

var VALID_COLOR: Material = load("res://assets/materials/Preview Valid.tres")
var INVALID_COLOR: Material = load("res://assets/materials/Preview Invalid.tres")
var DISABLED_COLOR: Material = load("res://assets/materials/Disabled.tres")

var good_spot: bool = false

func _ready():
	set_surface_override_material(0, DISABLED_COLOR)

func update_drag(cast_position: Vector3):
	good_spot = true
	global_position = Vector3(cast_position.x, 0.6, cast_position.z)
	var areas = collision_area.get_overlapping_areas()
	for area in areas:
		if area.get_parent() is AllySpawner:
			good_spot = false
	if good_spot:
		good_spot = false
		areas = link_area.get_overlapping_areas()
		for area in areas:
			if area.get_parent() is AllySpawner:
				good_spot = true
	if good_spot:
		set_surface_override_material(0, VALID_COLOR)
	else:
		set_surface_override_material(0, INVALID_COLOR)

func end_drag():
	set_surface_override_material(0, DISABLED_COLOR)
	good_spot = false

func spawn_position() -> Vector3:
	return Vector3(global_position.x, 0.5, global_position.z)

func confirm_position() -> bool:
	return good_spot
