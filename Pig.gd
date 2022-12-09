extends Area2D
class_name Pig

export(int) var speed = 200
export(int) var eatingTime = 2
export(float) var sizeScaler = 1.1
export(float) var speedScaler = 0.9

onready var animationPlayer: = $AnimationPlayer
onready var label: = $Label
onready var sprite: = $Sprite
onready var timerEating: = $TimerEating

const TextureVisible = preload("res://Pig.png")
const TextureHidden = preload("res://Pig_hidden.png")

var running = false
var hidden = false
var size = 1
var appleEating = null

enum State {
	IDLE,
	RUN,
	EATING,
	WOUNDED
}

var state = State.IDLE


func _ready():
	sprite.texture = TextureVisible

func _process(delta):
	running = false
	label.text = State.keys()[state]
	var direction = get_direction()

	match state:
		State.IDLE: process_state_idle(direction, delta)
		State.RUN: process_state_run(direction, delta)
		State.EATING: process_state_eating(direction, delta)
		State.WOUNDED: process_state_wounded(direction, delta)

func apple_eat_ini(apple):
	set_state(State.EATING)
	appleEating = apple
	timerEating.start(eatingTime)

func apple_eat_end():
	appleEating.queue_free()
	set_state(State.IDLE)
	size *= sizeScaler
	speed *= speedScaler
	scale = Vector2(size if scale.x > 0 else -size, size)

func set_hidden(value):
	hidden = value
	if hidden:
		sprite.texture = TextureHidden
	else:
		sprite.texture = TextureVisible

func move(_direction, delta):
	running = true
	position += _direction * speed * delta


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

func process_state_eating(_direction, _delta):
	animationPlayer.play("Eating")

func process_state_wounded(direction, delta):
	pass

func set_state(value):
	print("set_state: ", value);
	state = value

func get_direction():
	var result = Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		result = Vector2(-1, 0)

	if Input.is_action_pressed("ui_right"):
		result = Vector2(1, 0)

	if Input.is_action_pressed("ui_down"):
		result = Vector2(0, 1)

	if Input.is_action_pressed("ui_up"):
		result = Vector2(0, -1)

	return result

func look_towards_direction(direction):
	if direction.x > 0:
		scale.x = size
	elif direction.x < 0:
		scale.x = -size


func _on_Pig_area_entered(area:Area2D):
	if area is Apple:
		apple_eat_ini(area)

func _on_TimerEating_timeout():
	apple_eat_end()

func _on_BodyArea_area_exited(area:Area2D):
	if area is WorldTree:
		set_hidden(false)

func _on_BodyArea_area_entered(area:Area2D):
	if area is WorldTree:
		set_hidden(true)
