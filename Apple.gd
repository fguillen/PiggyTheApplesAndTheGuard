extends Area2D
class_name Apple

onready var tween: = $Tween
onready var collision: = $CollisionShape2D

func fall_from_sky(destiny_position):
	global_position = Vector2(destiny_position.x, -20)
	collision.disabled = true
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


func _on_Tween_tween_completed(object:Object, key:NodePath):
	collision.disabled = false
