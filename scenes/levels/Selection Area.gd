extends MeshInstance3D
class_name SelectionArea

var start_position: Vector3
@onready var collision_shape: Area3D = $Area3D

var ACTIVE_COLOR: Color = Color(.5, .5, 1, 0.2)
var DISABLED_COLOR: Color = Color(0, 0, 0, 0)
var SELECTION_HEIGHT: float = 3

func _ready():
	set_instance_shader_parameter("color", DISABLED_COLOR);

func begin_drag(cast_position: Vector3):
	start_position = Vector3(cast_position.x, SELECTION_HEIGHT/2, cast_position.z)
	global_position = start_position
	scale = Vector3(0, SELECTION_HEIGHT, 0)
	set_instance_shader_parameter("color", ACTIVE_COLOR);

func update_drag(cast_position: Vector3):
	var x_length: float = abs(cast_position.x - start_position.x)
	var z_length: float = abs(cast_position.z - start_position.z)
	var x_min: float = min(cast_position.x, start_position.x)
	var z_min: float = min(cast_position.z, start_position.z)
	global_position = Vector3(x_min + x_length/2, SELECTION_HEIGHT/2, z_min + z_length/2)
	scale = Vector3(x_length, SELECTION_HEIGHT, z_length)

func end_drag():
	set_instance_shader_parameter("color", DISABLED_COLOR);

func match_position(position: Vector3):
	return position.x == start_position.x and position.z == start_position.z

func get_selection() -> Array[Unit]:
	var bodies = collision_shape.get_overlapping_bodies()
	var units: Array[Unit] = []
	for body in bodies:
		if body.is_in_group("Unit"):
			units.append(body)
	return units
