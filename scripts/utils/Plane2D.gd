var normal: Vector2
var d: float


func _init(p1, p2):
	var vec = (p2 - p1).normalized()
	normal = Vector2(-vec.y, vec.x)
	d = normal.dot(p1)


func distance_to(point):
	return normal.dot(point) - d


func is_point_over(point):
	return distance_to(point) > 0


func clamp(point):
	if not is_point_over(point):
		return point
	return point - normal * distance_to(point)
