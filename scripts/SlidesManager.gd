extends Node

export (NodePath) var slide_container_path = null

var _available_slides = {}
var _slide_history = []


func init_post_ready(available_slides):
	_available_slides = available_slides


func open(slide):
	if not slide in _available_slides:
		return
	_remove_current_slide_if_any()
	_establish_new_slide(slide)


func back():
	var previous_slide = _slide_history.back()
	if previous_slide:
		_remove_current_slide_if_any()
		_establish_new_slide(previous_slide)


func _remove_current_slide_if_any():
	var slide_container = get_node(slide_container_path)
	for child in slide_container.get_children():
		_slide_history.append(child.name)
		slide_container.remove_child(child)
		child.queue_free()


func _establish_new_slide(slide):
	var slide_container = get_node(slide_container_path)
	var slide_instance = _available_slides[slide].instance()
	slide_container.add_child(slide_instance)
