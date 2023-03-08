@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("virtual_joystick", "Node2D", preload("res://addons/virtual_joystick/scripts/virtual_joystick.gd"), preload("res://addons/virtual_joystick/sprites/icon.png"))

func _exit_tree() -> void:
	remove_custom_type("virtual_joystick")
