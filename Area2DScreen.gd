extends Area2D
class_name AreaScreen

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	var collision_shape: = $CollisionShape2D
	var screen_center_position = screen_size / 2
	var offset_screen_size = (screen_size - Vector2(20, 20)) / 2

	print("screen_size: ", screen_size, offset_screen_size)

	position = screen_center_position
	collision_shape.shape.extents = offset_screen_size
