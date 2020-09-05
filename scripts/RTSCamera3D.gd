extends Camera

# TODO: calculate in 3D instead of 2D

const EXPECTED_X_ROTATION_DEGREES = -30.0
const EXPECTED_Y_ROTATION_DEGREES = 45.0

export var margin := 1
export var movement_speed := 1.1
export var rotation_speed := 0.005
export var camera_size_max := 20
export (int, LAYERS_3D_PHYSICS) var collision_mask := 0

var _movement_vector = Vector2(0, 0)
var _pivot_point_2d = null
var _pivot_point_3d = null
var _camera_point_3d = null


func _ready():
	assert(Utils.Float.approx_eq(rotation_degrees.x, EXPECTED_X_ROTATION_DEGREES, 0.01))
	assert(Utils.Float.approx_eq(rotation_degrees.y, EXPECTED_Y_ROTATION_DEGREES, 0.01))


# TODO: split
func _unhandled_input(event):
	if event is InputEventMouseButton:
		# TODO: input map
		if event.is_pressed() and event.button_index == BUTTON_WHEEL_UP:
			size = clamp(size - 1, 1, camera_size_max)
		if event.is_pressed() and event.button_index == BUTTON_WHEEL_DOWN:
			size = clamp(size + 1, 1, camera_size_max)
		if event.is_pressed() and event.button_index == BUTTON_MIDDLE and event.doubleclick:
			var pivot_point_3d = _calculate_pivot_point_3d()
			if pivot_point_3d == null:
				return
			var camera_point_3d = global_transform.origin
			var camera_point_2d = Vector2(camera_point_3d.x, camera_point_3d.z)
			var pivot_point_2d = Vector2(pivot_point_3d.x, pivot_point_3d.z)
			var diff_vec = camera_point_2d - pivot_point_2d
			var new_camera_point_2d = (
				pivot_point_2d
				+ Vector2(0.5, 0.5).normalized() * diff_vec.length()
			)
			global_transform.origin = Vector3(
				new_camera_point_2d.x, camera_point_3d.y, new_camera_point_2d.y
			)
			global_transform = global_transform.looking_at(pivot_point_3d, Vector3(0, 1, 0))
		if event.is_pressed() and event.button_index == BUTTON_MIDDLE:
			_pivot_point_3d = _calculate_pivot_point_3d()
			if _pivot_point_3d != null:
				_movement_vector = Vector2(0, 0)
				_pivot_point_2d = event.position
				_camera_point_3d = global_transform.origin
		if not event.is_pressed() and event.button_index == BUTTON_MIDDLE:
			_pivot_point_2d = null

	if event is InputEventMouseMotion:
		var mouse_pos = event.position

		if _pivot_point_2d != null:
			var strength = mouse_pos.x - _pivot_point_2d.x
			var camera_point_2d = Vector2(_camera_point_3d.x, _camera_point_3d.z)
			var pivot_point_2d = Vector2(_pivot_point_3d.x, _pivot_point_3d.z)
			var diff_vec = camera_point_2d - pivot_point_2d
			var rotated_diff_vec = diff_vec.rotated(strength * rotation_speed)
			var new_camera_point_2d = pivot_point_2d + rotated_diff_vec
			global_transform.origin = Vector3(
				new_camera_point_2d.x, _camera_point_3d.y, new_camera_point_2d.y
			)
			global_transform = global_transform.looking_at(_pivot_point_3d, Vector3(0, 1, 0))
			return

		var viewport_size = get_viewport().size

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
		var scaled_movement_vector_2d = (
			_movement_vector.normalized()
			* real_delta
			* Vector2(movement_speed, movement_speed * 2.0)
			* size
		)
		var movement_vector_3d = Vector3(scaled_movement_vector_2d.x, 0, scaled_movement_vector_2d.y).rotated(
			Vector3(0, 1, 0), rotation.y
		)
		global_translate(movement_vector_3d)


func get_ray_intersection(mouse_pos = null, a_collision_mask = null):
	if mouse_pos == null:
		mouse_pos = get_viewport().get_mouse_position()
	if a_collision_mask == null:
		a_collision_mask = collision_mask
	var ray_begin = project_ray_origin(mouse_pos)
	var ray_end = ray_begin + project_ray_normal(mouse_pos) * 1000
	var space_state = get_world().direct_space_state
	var ray_intersection = space_state.intersect_ray(ray_begin, ray_end, [], a_collision_mask)
	if 'position' in ray_intersection:
		return ray_intersection['position']
	return null


func set_position_safely(target_position: Vector3):
	var screen_center_pos_2d = get_viewport().size / 2.0
	var camera_ray = project_ray_normal(screen_center_pos_2d)
	var target_plane = Plane(0, 1, 0, target_position.y)
	var intersection = target_plane.intersects_ray(transform.origin, camera_ray)
	var offset = target_position - intersection
	offset.y = 0.0  # it may be not be exactly 0 but e.g. -0.000003 so let's force 0
	transform.origin += offset


func _calculate_pivot_point_3d():
	var screen_center_pos_2d = get_viewport().size / 2.0
	return get_ray_intersection(screen_center_pos_2d, collision_mask)
