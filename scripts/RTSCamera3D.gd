extends Camera

export var margin := 1
export var movement_speed := 1.1
export var camera_size_max := 20

var _movement_vector = Vector2(0, 0)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_WHEEL_UP:
			size -= 1
		if event.is_pressed() and event.button_index == BUTTON_WHEEL_DOWN:
			size += 1
		size = clamp(size, 1, camera_size_max)

	if event is InputEventMouseMotion:
		var viewport_size = get_viewport().size
		var mouse_pos = event.position

		if mouse_pos.x <= margin:
			_movement_vector.x = -1
		elif mouse_pos.x >= viewport_size.x - margin:
			_movement_vector.x = 1
		else:
			_movement_vector.x = 0

		if mouse_pos.y <= margin:
			_movement_vector.y = -1
		elif mouse_pos.y >= viewport_size.y - margin:
			_movement_vector.y = 1
		else:
			_movement_vector.y = 0


func _physics_process(delta):
	if _movement_vector != Vector2(0, 0):
		var real_delta = delta / Engine.time_scale
		var movement_vector_3d = Vector3(_movement_vector.x, 0, _movement_vector.y).rotated(
			Vector3(0, 1, 0), rotation.y
		)
		global_translate(movement_vector_3d * real_delta * movement_speed * size)
