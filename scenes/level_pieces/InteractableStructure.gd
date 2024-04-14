class_name InteractableThing
extends CharacterBody3D

var next_spot: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_interacting():
	print("starting interaction")
	

func interact_with():
	print("interacted with")

func get_spot() -> Vector3:
	print("getting spot")
	return Vector3.ZERO

func rotate_spot():
	next_spot += 1
	var spots: Array[Node] = $InteractionPoints.get_children()
	if next_spot >= spots.size():
		next_spot = 0
