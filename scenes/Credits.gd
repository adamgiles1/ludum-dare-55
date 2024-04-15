extends Node3D

@onready var menu_button: Button = $Control/Button

# Called when the node enters the scene tree for the first time.
func _ready():
	menu_button.connect("pressed", back_to_menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func back_to_menu():
	get_tree().change_scene_to_file("res://scenes/levels/MainMenu.tscn")
