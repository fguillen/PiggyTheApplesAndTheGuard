extends Area2D
class_name Pig

export(int) var speed = 200
export(Vector2) var eatingTime = Vector2(1, 3)
export(float) var sizeScaler = 1.1
export(float) var speedScaler = 0.9

onready var animationPlayer: = $AnimationPlayer
onready var label: = $Label
onready var labelVisible: = $LabelVisible
onready var sprite: = $Sprite
onready var timerEating: = $TimerEating
onready var visibilityNotifier: = $VisibilityNotifier2D
onready var audioPlayer: = $AudioStreamPlayer2D

const TextureVisible = preload("res://Pig.png")
const TextureHidden = preload("res://Pig_hidden.png")
const SoundChewing = preload("res://Sounds/Chewing.wav")

var hidden = false
var size = 1
var appleEating = null
var screen_size = Vector2.ZERO
var rnd = RandomNumberGenerator.new()

enum State {
	IDLE,
	RUN,
	EATING,
	WOUNDED
}

var state = State.IDLE


func _ready():
	sprite.texture = TextureVisible
	screen_size = get_viewport().get_visible_rect().size
	rnd.randomize()


func _process(delta):
	label.text = State.keys()[state]
	labelVisible.set_global_position(Vector2(100, 100))
	labelVisible.text = "true" if visibilityNotifier.is_on_screen() else "no"
	var direction = get_direction()

	match state:
		State.IDLE: process_state_idle(direction, delta)
		State.RUN: process_state_run(direction, delta)
		State.EATING: process_state_eating(direction, delta)
		State.WOUNDED: process_state_wounded(direction, delta)


func apple_eat_ini(apple):
	set_state(State.EATING)
	apple.eating()
	appleEating = apple
	var actual_eating_time = rnd.randf_range(eatingTime.x, eatingTime.y)
	timerEating.start(actual_eating_time)
	audioPlayer.stream = SoundChewing
	audioPlayer.pitch_scale = actual_eating_time / eatingTime.y
	audioPlayer.play()


func apple_eat_end():
	audioPlayer.stop()
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
	var old_position = position
	position += _direction * speed * delta

	if(
		position.x > screen_size.x - 20 or
		position.x < 20 or
		position.y > screen_size.y - 20 or
		position.y < 20
	):
		position = old_position


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


func process_state_wounded(_direction, _delta):
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


func wounded(arrow):
	print("Pig wounded!!")
	var old_transform = arrow.global_transform
	arrow.get_parent().remove_child(arrow)
	add_child(arrow)
	arrow.global_transform = old_transform
	arrow.z_index = 30
	arrow.stick()


func _on_PigMouth_area_entered(area:Area2D):
	if area is Apple:
		apple_eat_ini(area)


# Timers

func _on_TimerEating_timeout():
	apple_eat_end()


# Collisions

func _on_BodyArea_area_exited(area:Area2D):
	if area is WorldTree:
		set_hidden(false)


func _on_BodyArea_area_entered(area:Area2D):
	if area is WorldTree:
		set_hidden(true)
