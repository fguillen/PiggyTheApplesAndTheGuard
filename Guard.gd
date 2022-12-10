extends Area2D
class_name Guard

onready var timerNextPosition: = $TimerNextPosition
onready var timerAim: = $TimerAim
onready var timerAttack: = $TimerAttack
onready var timerSurprise: = $TimerSurprise
onready var label: = $Label
onready var labelState: = $LabelState
onready var labelVisible: = $LabelVisible
onready var animationPlayer: = $AnimationPlayer
onready var visionCollision: = $VisionSensor/CollisionPolygon2D
onready var spriteSurprise: = $SpriteSurprise
onready var arrowHolder: = $ArrowHolder
onready var spriteNextPosition: = $SpriteNextPosition
onready var audioPlayer: = $AudioStreamPlayer2D

export(Vector2) var speedRange = Vector2(10, 80)
export(Vector2) var changeDirectionTime = Vector2(1, 3)
export(Vector2) var aimTime = Vector2(0.1, 0.5)
export(Vector2) var attackTime = Vector2(2, 4)

const Arrow = preload("res://Arrow.tscn")
const SoundHei = preload("res://Sounds/Hei.wav")

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var rnd = RandomNumberGenerator.new()
var current_arrow
var is_visible = false
var screen_size = Vector2.ZERO
var next_position = Vector2.ZERO

enum State {
	IDLE,
	RUN,
	AIM,
	ATTACK
}

var state = State.IDLE

func _ready():
	unsurpise()
	set_visible(false)
	rnd.randomize()
	random_next_position()
	screen_size = get_viewport().get_visible_rect().size


func _process(delta):
	# label.text = State.keys()[state]
	label.text = "%.1f" % timerNextPosition.time_left
	labelState.text = State.keys()[state]
	labelVisible.text = "true" if visionCollision.disabled else "false"
	spriteNextPosition.global_position = next_position

	match state:
		State.IDLE: process_state_idle(direction, delta)
		State.RUN: process_state_run(direction, delta)
		State.AIM: process_state_aim(direction, delta)
		State.ATTACK: process_state_attack(direction, delta)


func random_next_position():
	next_position = Vector2(
			rnd.randi_range(20, screen_size.x - 20),
			rnd.randi_range(20, screen_size.y - 20)
		)
	print("random_next_position: ", next_position)

	if((next_position - global_position).length() > 100):
		next_position = global_position + ((next_position - global_position).normalized() * 100)
		print("random_next_position_reduced: ", next_position)

	set_direction()


func set_direction():
	var global_direction = next_position - global_position
	if abs(global_direction.x) > abs(global_direction.y):
		direction = Vector2(global_direction.x, 0).normalized()
	else:
		direction = Vector2(0, global_direction.y).normalized()

	print("set_direction: ", direction)
	set_random_velocity()
	look_towards_direction()


func set_random_velocity():
	velocity = direction * rnd.randf_range(speedRange.x, speedRange.y)
	animationPlayer.playback_speed = velocity.length() / speedRange.y


func look_towards_direction():
	if direction.x > 0:
		scale.x = 1
	elif direction.x < 0:
		scale.x = -1


func process_state_idle(_direction, _delta):
	animationPlayer.play("Idle")

	# Change state
	if direction.length() > 0:
		set_state(State.RUN)


func process_state_run(_direction, delta):
	animationPlayer.play("Run")

	move(_direction, delta)

	if((position - next_position).length() < 10):
		position_arrived()
	# elif( > 0)
	# 	print()
	elif(direction.dot((next_position - global_position)) < 5):
		set_direction()

	# print("angle_to: ", direction.dot((next_position - global_position)))

	# Change state
	if direction.length() == 0:
		set_state(State.IDLE)

func process_state_aim(_direction, _delta):
	animationPlayer.play("Aim")


func process_state_attack(_direction, _delta):
	animationPlayer.play("Attack")


func move(_direction, delta):
	position += velocity * delta


func set_state(value):
	print("set_state: ", State.keys()[state])
	state = value


func attack():
	set_state(State.ATTACK)
	timerSurprise.start(1)
	current_arrow.shoot()
	timerAttack.start(rnd.randf_range(attackTime.x, attackTime.y))


func surpise():
	audioPlayer.stream = SoundHei
	audioPlayer.play()
	spriteSurprise.visible = true


func unsurpise():
	spriteSurprise.visible = false


func aim(target_position):
	set_state(State.AIM)
	surpise()
	# visionCollision.disabled = true
	current_arrow = Arrow.instance()
	get_tree().get_root().add_child(current_arrow)
	print("Aim")
	current_arrow.aim(arrowHolder.global_position, target_position)
	timerAim.start(rnd.randf_range(aimTime.x, aimTime.y))


func set_visible(value):
	print("set_visible: ", value)
	is_visible = value
	# visionCollision.disabled = false if value else true


func position_arrived():
	print("position_arrived()")
	direction = Vector2.ZERO
	set_state(State.IDLE)
	timerNextPosition.start(rnd.randf_range(changeDirectionTime.x, changeDirectionTime.y))

# Timers

func _on_TimerAim_timeout():
	attack()


func _on_TimerAttack_timeout():
	# visionCollision.disabled = false
	position_arrived()


func _on_Timer_timeout():
	if state == State.RUN or state == State.IDLE:
		random_next_position()


func _on_TimerSurprise_timeout():
	unsurpise()


func _on_TimerNextPosition_timeout():
	random_next_position()
	set_state(State.RUN)


# Collisions

func _on_VisionSensor_area_entered(area:Area2D):
	if area is PigBody and not area.pig.hidden:
		aim(area.global_position)
