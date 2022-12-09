extends Area2D
class_name Apple

onready var tween: = $Tween

func fall_from_sky(destiny_position):
	global_position = Vector2(destiny_position.x, -20)
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
