tool
extends EditorPlugin

const UTILS_AUTOLOAD = "Utilities"


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
	add_autoload_singleton(
		UTILS_AUTOLOAD, "res://addons/sconys-godot-utilities/scripts/utils/Utils.tscn"
	)


func _exit_tree():
	remove_autoload_singleton(UTILS_AUTOLOAD)
	remove_custom_type("ReducedTextureButton")
	remove_custom_type("Circle2D")
