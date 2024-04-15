extends CPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.GAME_WON.connect(begin)

func begin():
	emitting = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(Vector3.UP, 1)

