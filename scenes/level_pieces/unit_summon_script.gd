extends Node3D
class_name AllySpawner

@export
var unit_to_summon: PackedScene = preload("res://scenes/units/BaseUnit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.SPAWN_UNITS.connect(spawn_unit)
	global_position.y = 0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn_unit():
	var unit := unit_to_summon.instantiate()
	unit.position = self.position
	get_tree().root.add_child(unit)
