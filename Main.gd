tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"Circle2D", "Sprite", preload("./nodes/Circle2D.gd"), preload("./assets/icons/Node2D.svg")
	)
	add_custom_type(
		"ReducedTextureButton",
		"Button",
		preload("./nodes/ReducedTextureButton.gd"),
		preload("./assets/icons/Control.svg")
	)


func _exit_tree():
	remove_custom_type("ReducedTextureButton")
	remove_custom_type("Circle2D")
