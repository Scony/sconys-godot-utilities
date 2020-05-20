tool
extends Button

export (float, 0, 1, 0.01) var reduction_factor = 0.0 setget _set_reduction_factor
export (Texture) var reducible_icon = null setget _set_reducible_icon_texture

var _nine_patch_rect


func _ready():
	focus_mode = FOCUS_NONE
	var center_container = CenterContainer.new()
	center_container.anchor_left = 0
	center_container.anchor_top = 0
	center_container.anchor_right = 1
	center_container.anchor_bottom = 1
	center_container.mouse_filter = MOUSE_FILTER_IGNORE
	_nine_patch_rect = NinePatchRect.new()
	_nine_patch_rect.mouse_filter = MOUSE_FILTER_IGNORE
	_setup_nine_patch_rect_texture()
	_setup_nine_patch_rect_size()
	center_container.add_child(_nine_patch_rect)
	add_child(center_container)
	connect('resized', self, '_setup_nine_patch_rect_size')


func _set_reduction_factor(factor):
	reduction_factor = factor
	_setup_nine_patch_rect_size()


func _set_reducible_icon_texture(texture):
	reducible_icon = texture
	_setup_nine_patch_rect_texture()


func _setup_nine_patch_rect_texture():
	if _nine_patch_rect != null:
		_nine_patch_rect.texture = reducible_icon


func _setup_nine_patch_rect_size():
	if _nine_patch_rect != null:
		_nine_patch_rect.rect_min_size = rect_size * (1 - reduction_factor)
		_nine_patch_rect.rect_size = _nine_patch_rect.rect_min_size
