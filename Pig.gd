extends Area2D
class_name Pig

export(int) var speed = 200

onready var animationPlayer: = $AnimationPlayer
onready var label: = $Label

var running = false
var hidden = false
var direction = Vector2.ZERO

func _process(delta):
	running = false
	direction = Vector2.ZERO
	label.text = "true" if hidden else "false"

	if Input.is_action_pressed("ui_left"):
		direction = Vector2(-1, 0)

	if Input.is_action_pressed("ui_right"):
		direction = Vector2(1, 0)

	if Input.is_action_pressed("ui_down"):
		direction = Vector2(0, 1)

	if Input.is_action_pressed("ui_up"):
		direction = Vector2(0, -1)

	if direction.x > 0:
		scale.x = 1
	elif direction.x < 0:
		scale.x = -1

	if direction.length() > 0:
		move(direction, delta)
		animationPlayer.play("Run")
	else:
		animationPlayer.play("Idle")

func _on_Pig_area_entered(area:Area2D):
	if area is WorldTree:
		hidden = true

	if area is Apple:
		collect_apple(area)

func collect_apple(apple):
	apple.queue_free()

func move(_direction, delta):
	running = true
	position += _direction * speed * delta


func _on_Pig_area_exited(area:Area2D):
	if area is WorldTree:
		hidden = false
