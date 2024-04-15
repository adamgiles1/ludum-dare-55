extends Node3D

var is_played = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.GAME_WON.connect(show_pentagram)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_played:
		GameManager.play_first_video()
		is_played = true

func show_pentagram():
	$PentagramLine1.visible = true
	$PentagramLine2.visible = true
	$PentagramLine3.visible = true
	$PentagramLine4.visible = true
	$PentagramLine5.visible = true
