extends Area2D
class_name WorldLimit


func _on_WorldLimit_body_entered(body:Node):
	print("WorldLimit.collision: ", body.name)

	if body is Guard:
		body.world_limit_reached()
