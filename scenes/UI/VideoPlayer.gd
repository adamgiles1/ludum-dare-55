extends Node2D

@onready var player: VideoStreamPlayer = $VideoStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.VIDEO_IS_PLAYING.connect(queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !player.is_playing():
		print("closing intro video")
		queue_free()
