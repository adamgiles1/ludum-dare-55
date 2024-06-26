extends Node3D

@onready var play_butt: Button = $%PlayButton
@onready var back_butt: Button = $%BackButton
@onready var menu_holder: Control = $%MenuHolder
@onready var credits_butt: Button = $%CreditsButton

# Called when the node enters the scene tree for the first time.
func _ready():
	play_butt.connect("pressed", play)
	back_butt.connect("pressed", back)
	credits_butt.connect("pressed", view_credits)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play():
	get_tree().change_scene_to_file("res://scenes/levels/LevelOne.tscn")

func back():
	switch_menu("Main")

func switch_menu(menu: String):
	for child: Control in menu_holder.get_children():
		child.visible = child.name == menu

func view_credits():
	
	get_tree().change_scene_to_file("res://scenes/Credits.tscn")
