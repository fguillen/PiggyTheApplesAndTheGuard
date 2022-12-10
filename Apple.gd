extends Area2D
class_name Apple

onready var tween: = $Tween
onready var collision: = $CollisionShape2D
onready var animationPlayer: = $AnimationPlayer
onready var audioPlayer: = $AudioStreamPlayer2D

const SoundAppleFall = preload("res://Sounds/AppleFall.wav")
const SoundAppleLand = preload("res://Sounds/AppleLand.wav")

func fall_from_sky(destiny_position):
	global_position = Vector2(destiny_position.x, -20)
	collision.disabled = true
	audioPlayer.stream = SoundAppleFall
	audioPlayer.play()
	tween.interpolate_property(
		self,
		"global_position",
		global_position,
		destiny_position,
		1,
		Tween.TRANS_QUART,
		Tween.EASE_IN
	)
	tween.start()

func eating():
	animationPlayer.play("Eating")


func _on_Tween_tween_completed(_object:Object, _key:NodePath):
	collision.disabled = false
	animationPlayer.play("Land")
	audioPlayer.stream = SoundAppleLand
	audioPlayer.play()
