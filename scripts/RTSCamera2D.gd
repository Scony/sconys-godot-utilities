extends Camera2D

export var margin := 1
export var movement_speed := 1000
export var zoom_min := 0.1
export var zoom_max := 2.0
export (Rect2) var bounding_box = null setget _set_bounding_box

var bounding_planes = []

var _actual_bounding_box = null


func _unhandled_input(event):
	if event is InputEventMouseButton:
		var old_zoom = zoom
		if event.is_pressed() and event.button_index == BUTTON_WHEEL_UP:
			zoom -= Vector2(0.1, 0.1)
		if event.is_pressed() and event.button_index == BUTTON_WHEEL_DOWN:
			zoom += Vector2(0.1, 0.1)
		if event.is_pressed() and event.button_index == BUTTON_MIDDLE and event.doubleclick:
			zoom = Vector2(1.0, 1.0)
		zoom.x = clamp(zoom.x, zoom_min, zoom_max)
		zoom.y = clamp(zoom.y, zoom_min, zoom_max)
		var viewport_size = get_viewport().size * zoom
		if bounding_box.size.x < viewport_size.x or bounding_box.size.y < viewport_size.y:
			zoom = old_zoom
		_recalculate_actual_bounding_box()
		_fix_position()


func _process(delta):
	var movement_vec = _calculate_movement_direction().normalized()
	var real_delta = delta / Engine.time_scale
	if movement_vec != Vector2(0, 0):
		position += movement_vec * real_delta * movement_speed * zoom
		_fix_position()


func set_position_safely(a_position):
	position = a_position
	_fix_position()


func _fix_position():
	if _actual_bounding_box != null:
		position.x = clamp(position.x, _actual_bounding_box.position.x, _actual_bounding_box.end.x)
		position.y = clamp(position.y, _actual_bounding_box.position.y, _actual_bounding_box.end.y)
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


func _set_bounding_box(a_bounding_box):
	bounding_box = a_bounding_box
	_recalculate_actual_bounding_box()


func _recalculate_actual_bounding_box():
	var viewport_size = get_viewport().size * zoom
	var viewport_half_size = viewport_size / 2.0
	_actual_bounding_box = (
		null
		if bounding_box == null
		else Rect2(bounding_box.position + viewport_half_size, bounding_box.size - viewport_size)
	)
