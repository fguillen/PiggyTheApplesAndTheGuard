extends Area2D
class_name Arrow

onready var tween: = $Tween
onready var sprite: = $Sprite
onready var collision: = $CollisionShape2D

var destiny_position

func _ready():
	print("Arrow.ready")
	print("collision.disabled: ", collision.disabled)
	collision.disabled = true

# func _ready():
# 	aim(Vector2(0, 0))
# 	shoot(Vector2(150, 50))

func aim(aim_position, _destiny_position):
	print("Arrow.aim")
	print("collision.disabled: ", collision.disabled)
	global_position = aim_position
	destiny_position = _destiny_position
	if destiny_position.x < aim_position.x:
		scale.x = -1

func shoot():
	print("Arrow.shoot")
	print("collision.disabled: ", collision.disabled)
	collision.disabled = false
	tween.interpolate_property(
		self,
		"global_position",
		global_position,
		destiny_position,
		0.8,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	tween.start()

func stick():
	collision.disabled = true
	sprite.rotation_degrees = rand_range(30, 110)
	sprite.frame = 1

func _on_Tween_tween_completed(_object:Object, _key:NodePath):
	stick()
