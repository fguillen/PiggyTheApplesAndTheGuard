extends Node

onready var timer: = $Timer
const Apple = preload("res://Apple.tscn")
var screen_size = Vector2.ZERO

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	spawn_apple()

func spawn_apple():
	var apple = Apple.instance()
	add_child(apple)
	apple.global_position = rand_position()
	timer.start(rand_range(2, 5))


func _on_Timer_timeout():
	spawn_apple()

func rand_position():
	var rng = RandomNumberGenerator.new()
	return Vector2(
		rng.randi_range(0, screen_size.x),
		rng.randi_range(0, screen_size.y)
	)
