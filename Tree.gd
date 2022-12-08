extends Area2D
class_name WorldTree

onready var sprite: = $Sprite

func _ready():
	sprite.frame = rand_range(0, sprite.hframes * sprite.vframes)
