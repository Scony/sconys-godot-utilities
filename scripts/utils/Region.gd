# gdlint: ignore=max-public-methods
const VON_NEUMANN_NEIGHBOURHOOD = [
	Vector2(0, 1),
	Vector2(0, -1),
	Vector2(1, 0),
	Vector2(-1, 0),
]
const MOORE_NEIGHBOURHOOD = [
	Vector2(-1, -1),
	Vector2(0, -1),
	Vector2(1, -1),
	Vector2(-1, 0),
	Vector2(0, 0),
	Vector2(1, 0),
	Vector2(-1, 1),
	Vector2(0, 1),
	Vector2(1, 1),
]

var _positions


func _init(positions):
	_positions = Utils.Set.from_array(positions)


func iterate():
	return _positions.iterate()


func size():
	return _positions.size()


func empty():
	return size() == 0


func has(position):
	return _positions.has(position)


func peek():
	for position in _positions.iterate():
		return position


func add(position):
	_positions.add(position)


func erase(position):
	_positions.erase(position)


func merge(positions):
	_positions.merge(positions)


func subtract(positions):
	if positions is Array:
		for position in positions:
			_positions.erase(position)
	else:  # assuming Region
		for position in positions.iterate():
			_positions.erase(position)


func intersect(region):
	for position in _positions.to_array():
		if not region.has(position):
			_positions.erase(position)


func get_random_position(rng):
	if _positions.empty():
		return null
	var positions = _positions.to_array()
	return positions[rng.randi() % positions.size()]


func get_n_random_positions(n, rng):
	if _positions.size() < n:
		return []
	var positions = _positions.to_array()
	Utils.Arr.shuffle(positions, rng)
	return Utils.Arr.slice(positions, 0, n)


func get_n_random_positions_w_duplicates(n, rng):
	var positions = _positions.to_array()
	var random_positions = []
	for _i in range(n):
		random_positions.append(positions[rng.randi() % positions.size()])
	return random_positions


func get_n_random_well_spread_positions(n, rng, samples_num = 10):
	"""Mitchell’s best-candidate algorithm"""
	var sampling_space = PoolVector2Array(_positions.to_array())
	var well_spread_points = PoolVector2Array([self.get_random_position(rng)])
	for _i in range(n - 1):
		var samples = PoolVector2Array()
		for _j in range(samples_num):
			samples.append(sampling_space[rng.randi() % sampling_space.size()])
		var evaluated_samples = []
		for sample in samples:
			var min_distance = null
			for point in well_spread_points:
				var distance_vec = (point - sample).abs()
				var distance = distance_vec.x + distance_vec.y
				if min_distance == null or distance < min_distance:
					min_distance = distance
			evaluated_samples.append([min_distance, sample])
		var max_min_distance = -1
		var max_min_sample = null
		for pair in evaluated_samples:
			if pair[0] > max_min_distance:
				max_min_distance = pair[0]
				max_min_sample = pair[1]
		well_spread_points.append(max_min_sample)
	return well_spread_points


func get_shortest_path_from_position_to_positions(source, positions, rng):
	var neighbourhood = VON_NEUMANN_NEIGHBOURHOOD.duplicate()
	Utils.Arr.shuffle(neighbourhood, rng)
	var position_to_source_direction = {}
	position_to_source_direction[source] = Vector2(0, 0)
	var visited_positions = {}
	var bfs_queue = [source]
	var destination = null
	while not bfs_queue.empty():
		var position = bfs_queue.pop_front()
		if position in visited_positions:
			continue
		if positions.has(position):
			destination = position
			break
		for offset in neighbourhood:
			var potential_position = position + offset
			if (
				self.has(potential_position)
				and not potential_position in position_to_source_direction
			):
				position_to_source_direction[potential_position] = offset * -1
				bfs_queue.push_back(potential_position)
	var path = [destination]
	var current_position = destination
	while position_to_source_direction[current_position] != Vector2(0, 0):
		path.push_back(current_position + position_to_source_direction[current_position])
		current_position = path.back()
	return path


func get_max_x():
	var max_x = null
	for position in _positions.iterate():
		if max_x == null:
			max_x = position.x
		elif position.x > max_x:
			max_x = position.x
	return max_x


func get_max_y():
	var max_y = null
	for position in _positions.iterate():
		if max_y == null:
			max_y = position.y
		elif position.y > max_y:
			max_y = position.y
	return max_y


func get_min_x():
	var min_x = null
	for position in _positions.iterate():
		if min_x == null:
			min_x = position.x
		elif position.x < min_x:
			min_x = position.x
	return min_x


func get_min_y():
	var min_y = null
	for position in _positions.iterate():
		if min_y == null:
			min_y = position.y
		elif position.y < min_y:
			min_y = position.y
	return min_y


func get_moore_border():
	"""border inside the region"""
	var border = Utils.Set.new()
	for position in _positions.iterate():
		for offset in MOORE_NEIGHBOURHOOD:
			if not _positions.has(position + offset):
				border.add(position)
				break
	return border.to_array()


func pop_moore_border():
	"""border inside the region"""
	var border = get_moore_border()
	subtract(border)
	return border


func get_moore_hull():
	"""border outside the region"""
	var hull = Utils.Set.new()
	for position in _positions.iterate():
		for offset in MOORE_NEIGHBOURHOOD:
			if not _positions.has(position + offset):
				hull.add(position + offset)
	return hull.to_array()


func get_moore_border_within_domain(domain):
	"""border inside the region and within domain"""
	var border = Utils.Set.new()
	for position in _positions.iterate():
		for offset in MOORE_NEIGHBOURHOOD:
			var neighbour = position + offset
			if not _positions.has(neighbour) and domain.has(neighbour):
				border.add(position)
				break
	return border.to_array()


func remove_moore_border_within_domain(domain):
	"""border inside the region and within domain"""
	var border = Utils.Set.new()
	for position in _positions.iterate():
		for offset in MOORE_NEIGHBOURHOOD:
			var neighbour = position + offset
			if not _positions.has(neighbour) and domain.has(neighbour):
				border.add(position)
				break
	for position in border.iterate():
		_positions.erase(position)


func add_moore_hull_within_domain(domain):
	"""border outside the region and within domain"""
	var hull = Utils.Set.new()
	for position in _positions.iterate():
		for offset in MOORE_NEIGHBOURHOOD:
			var neighbour = position + offset
			if not _positions.has(neighbour) and domain.has(neighbour):
				hull.add(neighbour)
	for position in hull.iterate():
		_positions.add(position)
