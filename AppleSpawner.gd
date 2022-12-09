extends Node

export(Vector2) var spawnTimeRange = Vector2(0.5, 10.0)

onready var timer: = $Timer
const Apple = preload("res://Apple.tscn")
var screen_size = Vector2.ZERO
var rng = RandomNumberGenerator.new()

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	spawn_apple()
	rng.randomize()

func spawn_apple():
	var apple = Apple.instance()
	add_child(apple)
	apple.fall_from_sky(rand_position())
	timer.start(rand_range(spawnTimeRange.x, spawnTimeRange.y))

func _on_Timer_timeout():
	spawn_apple()

func rand_position():
	return Vector2(
		rng.randi_range(40, screen_size.x - 40),
		rng.randi_range(40, screen_size.y - 40)
	)
