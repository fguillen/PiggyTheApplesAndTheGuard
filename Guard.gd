extends Node2D
class_name Guard

onready var timer: = $Timer
onready var label: = $Label
onready var animationPlayer: = $AnimationPlayer

export(Vector2) var speedRange = Vector2(10, 80)
export(Vector2) var changeDirectionTime = Vector2(1, 3)

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

enum State {
	IDLE,
	RUN,
	SURPRISE,
	ATTACK
}

var state = State.IDLE

func _ready():
	rng.randomize()
	random_direction()

func _process(delta):
	# label.text = State.keys()[state]
	label.text = "%.1f" % timer.time_left

	match state:
		State.IDLE: process_state_idle(direction, delta)
		State.RUN: process_state_run(direction, delta)
		State.SURPRISE: process_state_surprise(direction, delta)
		State.ATTACK: process_state_attack(direction, delta)

func random_direction():
	print("random_direction")
	set_direction(DIRECTIONS[randi() % DIRECTIONS.size()])

func invert_direction():
	print("invert direction")
	set_direction(direction * -1)

func set_direction(_direction):
	direction = _direction
	set_velocity()
	look_towards_direction(direction)

	print("direction: ", direction)
	print("velocity: ", velocity)
	print("scale.x: ", scale.x)

	timer.start(rng.randf_range(changeDirectionTime.x, changeDirectionTime.y))

func set_velocity():
	velocity = direction * rng.randf_range(speedRange.x, speedRange.y)

func _on_Timer_timeout():
	random_direction()

func world_limit_reached():
	print("world_limit_reached")
	invert_direction()

func look_towards_direction(direction):
	if direction.x > 0:
		scale.x = 1
	elif direction.x < 0:
		scale.x = -1

func pig_detected(area:Area2D):
	print("pig_detected:, ", area.global_position);

func _on_VisionSensor_area_entered(area:Area2D):
	if area is Pig:
		pig_detected(area)


func process_state_idle(direction, _delta):
	animationPlayer.play("Idle")

	# Change state
	if direction.length() > 0:
		set_state(State.RUN)

func process_state_run(direction, delta):
	animationPlayer.play("Run")

	look_towards_direction(direction)
	move(direction, delta)

	# Change state
	if direction.length() == 0:
		set_state(State.IDLE)

func process_state_surprise(direction, delta):
	pass

func process_state_attack(direction, delta):
	pass

func move(_direction, delta):
	position += velocity * delta

func set_state(value):
	state = value


func _on_EndOfWorldSensor_area_entered(area:Area2D):
	if area is WorldLimit:
		world_limit_reached()
