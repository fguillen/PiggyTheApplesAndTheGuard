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
onready var timerGoToGameOver: = $TimerGoToGameOver
onready var visibilityNotifier: = $VisibilityNotifier2D
onready var audioPlayer: = $AudioStreamPlayer

const TextureVisible = preload("res://Pig.png")
const TextureHidden = preload("res://Pig_hidden.png")
const SoundChewing = preload("res://Sounds/Chewing.wav")
const SoundOink = preload("res://Sounds/Oink.wav")

var hidden = false
var size = 1
var appleEating = null
var screen_size = Vector2.ZERO
var rnd = RandomNumberGenerator.new()
var run_away_direction

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


func move_without_limits(direction, delta):
	position += direction * speed * delta


func move(direction, delta):
	var old_position = position
	position += direction * speed * delta

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


func process_state_wounded(_direction, delta):
	animationPlayer.play("Run")
	move_without_limits(run_away_direction, delta)

func set_state(value):
	print("set_state: ", value);
	state = value


func get_direction():
	var result = $Gamepad.direction

	if result != Vector2.ZERO:
		return result


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
	arrow.get_parent().call_deferred("remove_child", arrow)
	call_deferred("add_child", arrow)
	arrow.global_transform = old_transform
	arrow.z_index = 30
	arrow.stick()

	if arrow.aim_position.x < global_position.x:
		run_away_direction = Vector2(1, 0)
	else:
		run_away_direction = Vector2(-1, 0)

	audioPlayer.stream = SoundOink
	audioPlayer.pitch_scale = 1
	audioPlayer.play()

	speed = 150

	look_towards_direction(run_away_direction)
	timerGoToGameOver.start(4)

	set_state(State.WOUNDED)


func go_to_game_over_scene():
	var _r = get_tree().change_scene("res://GameOver.tscn")



# Timers

func _on_TimerEating_timeout():
	if state == State.EATING:
		apple_eat_end()


func _on_TimerGoToGameOver_timeout():
	go_to_game_over_scene()


# Collisions

func _on_BodyArea_area_exited(area:Area2D):
	if area is WorldTree:
		set_hidden(false)


func _on_BodyArea_area_entered(area:Area2D):
	if area is WorldTree:
		set_hidden(true)

func _on_PigMouth_area_entered(area:Area2D):
	if area is Apple:
		apple_eat_ini(area)
