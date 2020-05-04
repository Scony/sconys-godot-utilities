tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"Circle2D", "Sprite", preload("./nodes/Circle2D.gd"), preload("./assets/icons/Node2D.svg")
	)


func _exit_tree():
	remove_custom_type("Circle2D")
