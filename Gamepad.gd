extends CanvasLayer

signal direction_changed

onready var button_screen: = $ButtonScreen
onready var button_gamepad: = $ButtonGamepad
onready var small_circle: = $ButtonGamepad/SmallCircle

var direction = Vector2.ZERO
var gamepad_active = false

func _ready():
	gamepad_released()


func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if button_gamepad.is_pressed() or gamepad_active:
			set_direction(gamepad_direction(event.position))
			set_small_circle()

		elif button_screen.is_pressed():
			gamepad_active = true
			button_gamepad.visible = true
			button_gamepad.global_position = event.position - Vector2(button_gamepad.shape.radius, button_gamepad.shape.radius)

	if event is InputEventScreenTouch and not event.is_pressed():
		gamepad_released()

func gamepad_released():
	set_direction(Vector2.ZERO)
	set_small_circle()
	gamepad_active = false
	yield(get_tree().create_timer(2.0), "timeout")
	if not gamepad_active:
		button_gamepad.visible = false


func set_direction(value):
	direction = value
	print("set_direction: ", direction)
	emit_signal("direction_changed", direction)


func gamepad_direction(event_position):
	var center = gamepad_center()
	return (event_position - center).limit_length(button_gamepad.shape.radius) / button_gamepad.shape.radius


func set_small_circle():
	small_circle.global_position = gamepad_center() + (direction * button_gamepad.shape.radius)


func gamepad_center():
	return button_gamepad.position + Vector2(button_gamepad.shape.radius, button_gamepad.shape.radius)
