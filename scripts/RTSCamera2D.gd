extends Camera2D

export var margin := 1
export var movement_speed := 1000
export (Rect2) var bounding_box = null

var bounding_planes = []


# TODO: fix zoom (fix pos after zoom change)
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_WHEEL_UP:
			zoom -= Vector2(0.1, 0.1)
		if event.is_pressed() and event.button_index == BUTTON_WHEEL_DOWN:
			zoom += Vector2(0.1, 0.1)
		zoom.x = clamp(zoom.x, 0.1, 1.0)
		zoom.y = clamp(zoom.y, 0.1, 1.0)


func _physics_process(delta):
	var movement_vec = _calculate_movement_direction().normalized()
	var real_delta = delta / Engine.time_scale
	if movement_vec != Vector2(0, 0):
		position += movement_vec * real_delta * movement_speed
		_fix_position()


func set_position_safely(a_position):
	position = a_position
	_fix_position()


func _fix_position():
	if bounding_box != null:
		position.x = clamp(position.x, bounding_box.position.x, bounding_box.end.x)
		position.y = clamp(position.y, bounding_box.position.y, bounding_box.end.y)
	if not bounding_planes.empty():
		for plane in bounding_planes:
			position = plane.clamp(position)


func _calculate_movement_direction():
	var viewport_size = get_viewport_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	var movement_vector = Vector2(0, 0)

	if mouse_pos.x < margin:
		movement_vector.x = -1
	elif mouse_pos.x > viewport_size.x - 1 - margin:
		movement_vector.x = 1

	if mouse_pos.y < margin:
		movement_vector.y = -1
	elif mouse_pos.y > viewport_size.y - 1 - margin:
		movement_vector.y = 1

	return movement_vector
