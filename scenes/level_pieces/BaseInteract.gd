extends InteractableThing

@onready var white: MeshInstance3D = $MeshWhite
@onready var blue: MeshInstance3D = $MeshBlue
@onready var yellow: MeshInstance3D = $MeshYellow
@onready var red: MeshInstance3D = $MeshRed

var last_is_red = false

# Called when the node enters the scene tree for the first time.
func _ready():
	change_color("white")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_interacting():
	change_color("blue")

func interact_with():
	if (last_is_red):
		change_color("yellow")
		last_is_red = false
	else:
		change_color("red")
		UI.increase_wood(1)
		last_is_red = true

func get_spot() -> Vector3:
	rotate_spot()
	return $InteractionPoints.get_child(next_spot).global_position

func change_color(color: String):
	white.visible = false
	blue.visible = false
	yellow.visible = false
	red.visible = false
	match color:
		"white":
			white.visible = true
		"blue":
			blue.visible = true
		"yellow":
			yellow.visible = true
		"red":
			red.visible = true
