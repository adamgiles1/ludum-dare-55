extends Node2D

@onready var player: VideoStreamPlayer = $VideoStreamPlayer
@export var causes_credits := false
# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.VIDEO_IS_PLAYING.connect(die)
	GameManager.video_playing = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !player.is_playing():
		print("closing video")
		GameManager.video_playing = false
		die()

func die():
	if causes_credits:
		get_tree().change_scene_to_file("res://scenes/Credits.tscn")
	queue_free()

