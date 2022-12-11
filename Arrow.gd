extends Area2D
class_name Arrow

export(int) var speed = 100

onready var tween: = $Tween
onready var sprite: = $Sprite
onready var collision: = $CollisionShape2D
onready var audioPlayer: = $AudioStreamPlayer2D

const SoundArrowImpact = preload("res://Sounds/ArrowImpact.wav")
const SoundArrowShoot = preload("res://Sounds/ArrowShoot.wav")

var destiny_position
var aim_position

func _ready():
	print("Arrow.ready")
	print("collision.disabled: ", collision.disabled)


# func _ready():
# 	aim(Vector2(0, 0))
# 	shoot(Vector2(150, 50))

func aim(_aim_position, _destiny_position):
	print("Arrow.aim")
	collision.disabled = true
	aim_position = _aim_position
	destiny_position = _destiny_position

	global_position = aim_position

	if destiny_position.x < aim_position.x:
		scale.x = -1


func shoot():
	print("Arrow.shoot")
	print("collision.disabled: ", collision.disabled)
	audioPlayer.stream = SoundArrowShoot
	audioPlayer.play()
	collision.disabled = false
	var duration = (destiny_position - global_position).length() / speed
	tween.interpolate_property(
		self,
		"global_position",
		global_position,
		destiny_position,
		duration,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	tween.start()


func stick():
	audioPlayer.stream = SoundArrowImpact
	audioPlayer.play()
	collision.call_deferred("set_disabled", true)
	sprite.rotation_degrees = rand_range(30, 110)
	sprite.frame = 1


func _on_Tween_tween_completed(_object:Object, _key:NodePath):
	stick()


func _on_Arrow_area_entered(area:Area2D):
	print("Arrow.collision: ", area.name)
	if area is PigBody:
		area.pig.wounded(self)
