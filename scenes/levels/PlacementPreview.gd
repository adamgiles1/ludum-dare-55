extends MeshInstance3D
class_name PlacementPreview

@onready var collision_area: Area3D = $"Collision Area"
@onready var link_area: Area3D = $"Link Area"

var VALID_COLOR: Color = Color(0, 1, 1, 0.4)
var INVALID_COLOR: Color = Color(1, 0, 0, 0.4)
var DISABLED_COLOR: Color = Color(0, 0, 0, 0)

var good_spot: bool = false

func _ready():
	set_instance_shader_parameter("color", DISABLED_COLOR);

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
		set_instance_shader_parameter("color", VALID_COLOR);
	else:
		set_instance_shader_parameter("color", INVALID_COLOR);

func end_drag():
	set_instance_shader_parameter("color", DISABLED_COLOR);

func spawn_position() -> Vector3:
	return Vector3(global_position.x, 0.5, global_position.z)

func confirm_position() -> bool:
	return good_spot
