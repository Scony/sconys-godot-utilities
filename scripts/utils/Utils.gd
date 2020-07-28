tool
extends Node

const Region = preload('Region.gd')
const SetBase = preload('Set.gd')
const Plane2D = preload('Plane2D.gd')


func normalize_pos_to_tile_center(pos, tm):
	var tile_pos = tm.map_to_world(tm.world_to_map(pos))
	return tile_pos + Vector2(0, 32)


func copy_one_tile_map_to_another(one, another):
	for cell in one.get_used_cells():
		another.set_cellv(cell, one.get_cellv(cell))


func explode_mapping(mapping):
	var ret = {}
	for key in mapping:
		for subkey in key:
			ret[subkey] = mapping[key]
	return ret


class Scene:
	static func replace_and_free(old, new):
		var parent = old.get_parent()
		parent.remove_child(old)
		old.queue_free()
		parent.add_child(new)

	static func is_standalone(ref):
		return ref.get_parent() == ref.get_node('/root')


class Nod:
	static func move_children(from, to):
		for child in from.get_children():
			from.remove_child(child)
			to.add_child(child)

	static func move_child(node, from, to):
		from.remove_child(node)
		to.add_child(node)


class NodTree:
	class NodeGathererByName:
		var _nodes = []
		var _name = null

		func _init(name):
			_name = name

		func get_nodes():
			return _nodes

		func _gather_if_name_matches(node):
			if node.name == _name:
				_nodes.append(node)

	static func traverse(start, object, function_name):
		var nodes_to_visit = [start]
		while not nodes_to_visit.empty():
			var visited_node = nodes_to_visit.pop_back()
			object.call(function_name, visited_node)
			nodes_to_visit += visited_node.get_children()

	static func find_nodes(start, name):
		var node_gatherer = NodeGathererByName.new(name)
		traverse(start, node_gatherer, '_gather_if_name_matches')
		return node_gatherer.get_nodes()


class Line:
	static func length(line):
		var sum = 0.0
		for i in range(line.size() - 1):
			sum += line[i].distance_to(line[i + 1])
		return sum


class Order:
	static func asc0(a, b):
		if a[0] < b[0]:
			return true
		return false

	static func desc0(a, b):
		if a[0] > b[0]:
			return true
		return false

	static func desc1(a, b):
		if a[1] > b[1]:
			return true
		return false


class Dict:
	static func update(src, data):
		for key in data:
			src[key] = data[key]
		return src

	static func eq(d1, d2):
		return d1.hash() == d2.hash()

	static func subdict(src, keys_to_take):
		var sub_dict = {}
		for key in keys_to_take:
			sub_dict[key] = src[key]
		return sub_dict

	static func union2(d1, d2):
		var new_d = d1.duplicate(true)
		update(new_d, d2)
		return new_d

	static func default_initialized(keys, default_value):
		var d = {}
		for key in keys:
			d[key] = default_value
		return d

	static func items(d):
		var pairs = []
		for k in d:
			pairs.append([k, d[k]])
		return pairs


class Float:
	static func approx_eq(a: float, b: float, epsilon):
		return abs(a - b) <= epsilon


class Arr:
	static func sum(r):
		var total = 0
		for x in r:
			total += x
		return total

	static func sum1(r):
		var total = 0
		for x in r:
			total += x[1]
		return total

	static func shuffle(arr, rng = null):
		for _i in range(arr.size()):
			var random_index_1 = rng.randi() % arr.size() if rng != null else randi() % arr.size()
			var random_index_2 = rng.randi() % arr.size() if rng != null else randi() % arr.size()
			var tmp = arr[random_index_1]
			arr[random_index_1] = arr[random_index_2]
			arr[random_index_2] = tmp
		return arr

	static func slice(r, b, e = null):
		var ret = []
		var re = r.size() if e == null else e
		for i in range(b, min(re, r.size())):
			ret.append(r[i])
		return ret

	static func median(r):
		var arr = r.duplicate()
		arr.sort()
		if arr.size() % 2 == 1:
			return arr[arr.size() / 2]
		return (arr[floor(arr.size() / 2)] + arr[ceil(arr.size() / 2)]) / 2

	static func mean(r):
		return sum(r) / r.size()

	static func std_dev(r):
		var mn = mean(r)
		var pow_sum = 0
		for x in r:
			pow_sum += pow(x - mn, 2)
		return sqrt(pow_sum / r.size())

	static func uniq(r):
		return Set.from_array(r).to_array()


class Format:
	static func as_csv(rows):
		var text = ""
		for key in rows[0]:
			text += key + ";"
		text += "\n"
		for row in rows:
			for val in row.values():
				text += str(val) + ";"
			text += "\n"
		return text

	static func as_table(rows):
		var text = ""
		var key_paddings = {}
		for key in rows[0]:
			var key_padding = len(key) + 5
			key_paddings[key] = key_padding
			var fmt = '%' + str(key_paddings[key]) + 's'
			text += fmt % key
		text += "\n"
		for row in rows:
			for key in row:
				var val = row[key]
				var fmt = '%' + str(key_paddings[key]) + 's'
				text += fmt % str(val)
			text += "\n"
		return text


class RouletteWheel:
	var _values_w_sorted_normalized_shares = []

	func _init(value_to_share_mapping):
		var total_share = Arr.sum(value_to_share_mapping.values())
		for value in value_to_share_mapping:
			var share = value_to_share_mapping[value]
			var normalized_share = share / total_share
			_values_w_sorted_normalized_shares.append([value, normalized_share])
		for i in range(1, _values_w_sorted_normalized_shares.size()):
			_values_w_sorted_normalized_shares[i][1] += _values_w_sorted_normalized_shares[i - 1][1]

	func get_value(probability):
		for tuple in _values_w_sorted_normalized_shares:
			var value = tuple[0]
			var accumulated_share = tuple[1]
			if probability <= accumulated_share:
				return value
		assert(false)
		return -1


class Set:
	extends SetBase

	static func from_array(array):
		var set = Set.new()
		for item in array:
			set.add(item)
		return set


class Img:
	static func expand_x3_corner_smoothing(image):
		var pixels = {}
		image.lock()
		for x in image.get_width():
			for y in image.get_height():
				var position = Vector2(x, y)
				pixels[position] = image.get_pixelv(position)
		image.unlock()
		image.resize(image.get_width() * 3, image.get_height() * 3)
		image.lock()
		for original_position in pixels:
			var original_color = pixels[original_position]
			var new_position_base = original_position * 3
			for x in range(3):
				for y in range(3):
					image.set_pixelv(new_position_base + Vector2(x, y), original_color)
			for corner in [Vector2(-1, -1), Vector2(-1, 1), Vector2(1, 1), Vector2(1, -1)]:
				var neighbour_0_color = pixels.get(original_position + corner)
				var neighbour_1_color = pixels.get(original_position + Vector2(corner.x, 0))
				var neighbour_2_color = pixels.get(original_position + Vector2(0, corner.y))
				if (
					neighbour_0_color != null
					and neighbour_1_color != null
					and neighbour_2_color != null
					and neighbour_0_color == neighbour_1_color
					and neighbour_1_color == neighbour_2_color
				):
					image.set_pixelv(new_position_base + Vector2(1, 1) + corner, neighbour_0_color)
		image.unlock()

	static func scale_inplace(image: Image, factor: float, interpolation):
		var image_size = image.get_size()
		var target_size = image_size * factor
		image.resize(target_size.x, target_size.y, interpolation)

	static func calculate_binary_variance_map(source_image: Image, moore_radius: int = 1):
		var image_size = source_image.get_size()
		var image = Image.new()
		image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
		var source_pixels = {}
		source_image.lock()
		for x in range(image_size.x):
			for y in range(image_size.y):
				var pixel_pos = Vector2(x, y)
				var source_color = source_image.get_pixelv(pixel_pos)
				if source_color.a == 1.0:
					source_pixels[pixel_pos] = source_color
		source_image.unlock()
		var moore_neighbourhood = PoolVector2Array([])
		for x in range(-moore_radius, moore_radius + 1):
			for y in range(-moore_radius, moore_radius + 1):
				moore_neighbourhood.append(Vector2(x, y))
		image.lock()
		for x in range(image_size.x):
			for y in range(image_size.y):
				var pixel_pos = Vector2(x, y)
				if not pixel_pos in source_pixels:
					continue
				var variance = false
				for offset in moore_neighbourhood:
					var neighbour_pos = pixel_pos + offset
					if (
						not neighbour_pos in source_pixels
						or source_pixels[neighbour_pos] != source_pixels[pixel_pos]
					):
						image.set_pixelv(pixel_pos, Color(1.0, 1.0, 1.0))
						break
		image.unlock()
		return image

	static func get_non_transparent_region(image: Image):
		var image_size = image.get_size()
		var points = []
		image.lock()
		for x in range(image_size.x):
			for y in range(image_size.y):
				var pixel_pos = Vector2(x, y)
				var pixel_color = image.get_pixelv(pixel_pos)
				if pixel_color.a == 1.0:
					points.append(pixel_pos)
		image.unlock()
		return Utils.Region.new(points)


class HexTileMap:
	class XOffset:
		const ODD_Y_NEIGHBOURHOOD = [
			Vector2(0, -1),
			Vector2(1, -1),
			Vector2(-1, 0),
			Vector2(1, 0),
			Vector2(0, 1),
			Vector2(1, 1),
		]
		const EVEN_Y_NEIGHBOURHOOD = [
			Vector2(-1, -1),
			Vector2(0, -1),
			Vector2(-1, 0),
			Vector2(1, 0),
			Vector2(-1, 1),
			Vector2(0, 1),
		]


class Colour:
	static func approx_eq(a: Color, b: Color, epsilon: float):
		return abs(a.r - b.r) <= epsilon and abs(a.g - b.g) <= epsilon and abs(a.b - b.b) <= epsilon

	static func mean(colors):
		var sum = Vector3(0.0, 0.0, 0.0)
		for color in colors:
			sum += Vector3(color.r, color.g, color.b)
		var mean_color = sum / colors.size()
		return Color(mean_color.x, mean_color.y, mean_color.z)

	static func uniq_mean(colors):
		var uniq_colors = Arr.uniq(colors)
		var sum = Vector3(0.0, 0.0, 0.0)
		for color in uniq_colors:
			sum += Vector3(color.r, color.g, color.b)
		var mean_color = sum / uniq_colors.size()
		return Color(mean_color.x, mean_color.y, mean_color.z)


class Debug:
	static func not_implemented():
		assert(false)


class Algorithm:
	static func poisson_disc_sampling(area_size, radius, k, rng):
		var cell_side = radius / sqrt(2)
		var radius_squared = radius * radius
		var outer_radius = 2 * radius
		var outer_radius_squared = outer_radius * outer_radius
		var pi_times_2 = PI * 2
		var radiuses_diff = outer_radius_squared - radius_squared
		var starting_point = Vector2(
			rng.randf_range(0, area_size.x), rng.randf_range(0, area_size.y)
		)
		var starting_point_cell = Vector2(
			int(starting_point.x / cell_side), int(starting_point.y / cell_side)
		)
		var grid = {starting_point_cell: starting_point}
		var samples = [starting_point]
		var active_list = Utils.Set.from_array([0])
		while not active_list.empty():
			var random_index = active_list.peek_random(rng)
			var origin_sample = samples[random_index]
			var success = false
			for i in range(k):
				var u = rng.randf_range(0, 1)
				var v = rng.randf_range(0, 1)
				var theta = pi_times_2 * u
				var r = sqrt(radius_squared + v * radiuses_diff)
				var new_sample = Vector2(
					origin_sample.x + r * cos(theta), origin_sample.y + r * sin(theta)
				)
				var reject = (
					new_sample.x < 0
					or new_sample.x > area_size.x
					or new_sample.y < 0
					or new_sample.y > area_size.y
				)
				if reject:
					continue
				var new_sample_cell = Vector2(
					int(new_sample.x / cell_side), int(new_sample.y / cell_side)
				)
				for x in range(-2, 3):
					for y in range(-2, 3):
						var point = grid.get(new_sample_cell + Vector2(x, y))
						if point != null and new_sample.distance_to(point) < radius:
							reject = true
							break
				if reject:
					continue
				samples.append(new_sample)
				active_list.add(samples.size() - 1)
				grid[new_sample_cell] = new_sample
				success = true
				break
			if not success:
				active_list.erase(random_index)
		return samples


class Chunk2D:
	static func generate_chunks(area_size: Vector2, chunk_size: Vector2):
		var chunks = {}
		for x in range(int(floor(area_size.x / chunk_size.x)) + 1):
			for y in range(int(floor(area_size.y / chunk_size.y)) + 1):
				chunks[Vector2(x * chunk_size.x, y * chunk_size.y)] = []
		return chunks

	static func get_chunk(position, chunk_size: Vector2):
		if position is Vector3:
			return Vector2(
				floor(position.x / chunk_size.x) * chunk_size.x,
				floor(position.z / chunk_size.y) * chunk_size.y
			)
