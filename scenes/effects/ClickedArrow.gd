extends Node3D

var time_left: float = 3.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.HOVER_ARROW_SPAWNED.connect(die)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !animation_player.is_playing():
		animation_player.play("hovering")
	
	time_left -= delta
	
	if time_left <= 0:
		die()

func die():
	queue_free()
