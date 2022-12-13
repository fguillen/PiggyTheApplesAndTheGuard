extends CanvasLayer

signal direction_changed

onready var button_screen: = $ButtonScreen
onready var button_gamepad: = $ButtonGamepad
onready var small_circle: = $ButtonGamepad/SmallCircle

export(int) var position_margin = 5

var direction = Vector2.ZERO
var gamepad_active = false
var screen_size = Vector2.ZERO
var radius

func _ready():
	radius = button_gamepad.shape.radius
	screen_size = get_viewport().get_visible_rect().size
	gamepad_released()


func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if button_gamepad.is_pressed() or gamepad_active:
			set_direction(gamepad_direction(event.position))
			set_small_circle()

		elif button_screen.is_pressed():
			set_gamepad_position(event.position)


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
	return (event_position - center).limit_length(radius) / radius


func set_small_circle():
	small_circle.global_position = gamepad_center() + (direction * radius)


func gamepad_center():
	return button_gamepad.position + Vector2(radius, radius)


func set_gamepad_position(position):
	gamepad_active = true
	button_gamepad.visible = true

	if position.x > screen_size.x - radius - position_margin:
		position.x = screen_size.x - radius - position_margin
	if position.x < 0 + radius + position_margin:
		position.x = 0 + radius + position_margin
	if position.y > screen_size.y - radius - position_margin:
		position.y = screen_size.y - radius - position_margin
	if position.y < 0 + radius + position_margin:
		position.y = 0 + radius + position_margin

	button_gamepad.global_position = position - Vector2(radius, radius)
