extends Node

onready var label_desktop: = $CenterContainer/VBoxContainer/LabelDesktop
onready var label_mobile: = $CenterContainer/VBoxContainer/LabelMobile

func _ready():
	choose_label()

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		restart_game()


func _input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		restart_game()


func restart_game():
	var _r = get_tree().change_scene("res://World.tscn")


func choose_label():
	if OS.has_touchscreen_ui_hint():
		label_desktop.visible = false
		label_mobile.visible = true
	else:
		label_desktop.visible = true
		label_mobile.visible = false
