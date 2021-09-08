tool
extends Sprite

export(Color) var color = Color.white setget _set_color
export(int) var radius = 15 setget _set_radius
export(int) var internal_radius = 0 setget _set_internal_radius


func _ready():
	_change_texture()


func _change_texture():
	var script = get_script()
	if not script.has_meta("cache") or Engine.is_editor_hint():
		script.set_meta("cache", {})
	var cache = script.get_meta("cache")
	var color_hash = color.to_rgba32()
	if not color_hash in cache:
		cache[color_hash] = {}
	if not radius in cache[color_hash]:
		cache[color_hash][radius] = {}
	if not internal_radius in cache[color_hash][radius]:
		cache[color_hash][radius][internal_radius] = _create_new_texture()
	texture = cache[color_hash][radius][internal_radius]


func _create_new_texture():
	var image_size = Vector2(radius, radius) * 2
	var image_center = (image_size - Vector2(1, 1)) / 2.0
	var image = Image.new()
	image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	image.lock()
	for x in range(image_size.x):
		for y in range(image_size.y):
			var pixel_position = Vector2(x, y)
			var distance_to_center = pixel_position.distance_to(image_center)
			if distance_to_center <= internal_radius - 1:
				continue
			elif distance_to_center <= internal_radius:
				var diff = internal_radius - distance_to_center
				image.set_pixelv(pixel_position, Color(color.r, color.g, color.b, 1.0 - diff))
				continue
			if pixel_position.distance_to(image_center) <= radius - 1:
				image.set_pixelv(pixel_position, color)
			else:
				var diff = abs(pixel_position.distance_to(image_center) - radius + 1)
				if diff < 1.0:
					image.set_pixelv(pixel_position, Color(color.r, color.g, color.b, 1.0 - diff))
	image.unlock()
	var new_texture = ImageTexture.new()
	new_texture.create_from_image(image, Texture.FLAG_MIPMAPS)
	return new_texture


func _set_radius(new_radius):
	radius = new_radius
	_change_texture()


func _set_internal_radius(new_internal_radius):
	internal_radius = new_internal_radius
	_change_texture()


func _set_color(new_color):
	color = new_color
	_change_texture()
