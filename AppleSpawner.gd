extends Node

onready var timer: = $Timer
const Apple = preload("res://Apple.tscn")
var screen_size = Vector2.ZERO
var rng = RandomNumberGenerator.new()

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	spawn_apple()

func spawn_apple():
	var apple = Apple.instance()
	add_child(apple)
	apple.global_position = rand_position()
	print("Apple position: ", apple.global_position)
	timer.start(rand_range(0.5, 5.0))


func _on_Timer_timeout():
	spawn_apple()

func rand_position():
	return Vector2(
		rng.randi_range(40, screen_size.x - 40),
		rng.randi_range(40, screen_size.y - 40)
	)
