extends Node2D
class_name Guard

onready var timer: = $Timer
onready var timerAim: = $TimerAim
onready var timerAttack: = $TimerAttack
onready var label: = $Label
onready var labelState: = $LabelState
onready var animationPlayer: = $AnimationPlayer
onready var visionCollision: = $VisionSensor/CollisionPolygon2D

export(Vector2) var speedRange = Vector2(10, 80)
export(Vector2) var changeDirectionTime = Vector2(1, 3)
export(Vector2) var aimTime = Vector2(0.1, 0.5)
export(Vector2) var attackTime = Vector2(2, 4)

const Arrow = preload("res://Arrow.tscn")

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var rng = RandomNumberGenerator.new()
var current_arrow

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
	AIM,
	ATTACK
}

var state = State.IDLE

func _ready():
	rng.randomize()
	random_direction()

func _process(delta):
	# label.text = State.keys()[state]
	label.text = "%.1f" % timer.time_left
	labelState.text = State.keys()[state]

	match state:
		State.IDLE: process_state_idle(direction, delta)
		State.RUN: process_state_run(direction, delta)
		State.AIM: process_state_aim(direction, delta)
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

	# print("direction: ", direction)
	# print("velocity: ", velocity)
	# print("scale.x: ", scale.x)

	timer.start(rng.randf_range(changeDirectionTime.x, changeDirectionTime.y))

func set_velocity():
	velocity = direction * rng.randf_range(speedRange.x, speedRange.y)



func world_limit_reached():
	print("world_limit_reached")
	invert_direction()

func look_towards_direction(direction):
	if direction.x > 0:
		scale.x = 1
	elif direction.x < 0:
		scale.x = -1





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

func process_state_aim(direction, delta):
	animationPlayer.play("Aim")

func process_state_attack(direction, delta):
	animationPlayer.play("Attack")

func move(_direction, delta):
	position += velocity * delta

func set_state(value):
	state = value



func attack():
	set_state(State.ATTACK)
	current_arrow.shoot()
	timerAttack.start(rng.randf_range(attackTime.x, attackTime.y))



func aim(target_position):
	set_state(State.AIM)
	visionCollision.disabled = true
	print("Instantiation")
	current_arrow = Arrow.instance()
	get_tree().get_root().add_child(current_arrow)
	print("Aim")
	current_arrow.aim(global_position, target_position)
	timerAim.start(rng.randf_range(aimTime.x, aimTime.y))


func _on_EndOfWorldSensor_area_entered(area:Area2D):
	if area is WorldLimit:
		world_limit_reached()


func _on_VisionSensor_area_entered(area:Area2D):
	if area is Pig and not area.hidden:
		aim(area.global_position)


func _on_TimerAim_timeout():
	attack()


func _on_TimerAttack_timeout():
	visionCollision.disabled = false
	random_direction()
	set_state(State.IDLE)


func _on_Timer_timeout():
	if state == State.RUN or state == State.IDLE:
		random_direction()
