extends Node

const RegionBase = preload('Region.gd')
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


class Region:
	extends RegionBase

	func _init(positions).(positions):
		pass

	static func calculate_von_neumann_overlay(positions):
		var positions_set = Set.from_array(positions)
		var overlay = Set.new()
		for position in positions:
			for offset in VON_NEUMANN_NEIGHBOURHOOD:
				var potential_overlay_position = position + offset
				if not positions_set.has(potential_overlay_position):
					overlay.add(potential_overlay_position)
		return overlay.to_array()


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
