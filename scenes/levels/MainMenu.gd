extends Node3D

@onready var play_butt: Button = $%PlayButton
@onready var options_butt: Button = $%OptionsButton
@onready var exit_butt: Button = $%ExitButton
@onready var back_butt: Button = $%BackButton
@onready var menu_holder: Control = $%MenuHolder

# Called when the node enters the scene tree for the first time.
func _ready():
	play_butt.connect("pressed", play)
	options_butt.connect("pressed", options)
	exit_butt.connect("pressed", exit)
	back_butt.connect("pressed", back)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play():
	get_tree().change_scene_to_file("res://scenes/levels/LevelOne.tscn")

func options():
	switch_menu("Option")

func back():
	switch_menu("Main")

func exit():
	pass

func switch_menu(menu: String):
	for child: Control in menu_holder.get_children():
		child.visible = child.name == menu
