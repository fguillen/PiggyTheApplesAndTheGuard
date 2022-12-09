extends KinematicBody2D
class_name Guard

onready var timer: = $Timer

export(float) var speed_max = 2.0
export(float) var change_direction_max_seconds = 3.0

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var rng = RandomNumberGenerator.new()

var DIRECTIONS = [
	Vector2(0, 0),
	Vector2(0, -1),
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(-1, 0)
]

func _ready():
	rng.randomize()
	change_direction()

func _physics_process(_delta):
	var _collision = move_and_collide(velocity)

func change_direction():
	set_direction(DIRECTIONS[randi() % DIRECTIONS.size()])

func invert_direction():
	print("invert direction")
	set_direction(direction * -1)

func set_direction(_direction):
	direction = _direction
	set_velocity()
	look_towards_direction()

	print("direction: ", direction)
	print("velocity: ", velocity)
	print("scale.x: ", scale.x)

	timer.start(rng.randf_range(change_direction_max_seconds / 3.0, change_direction_max_seconds))

func set_velocity():
	velocity = direction * rng.randf_range(speed_max / 3, speed_max)

func _on_Timer_timeout():
	change_direction()

func world_limit_reached():
	invert_direction()

func look_towards_direction():
	if direction.x > 0:
		scale.x = 1
	elif direction.x < 0:
		scale.x = -1

func pig_detected(area:Area2D):
	print("pig_detected:, ", area.global_position);

func _on_VisionSensor_area_entered(area:Area2D):
	if area is Pig:
		pig_detected(area)
