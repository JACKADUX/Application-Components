class_name FPWS extends Node

@export var enable:= true

func _ready() -> void:
	if enable or not OS.is_debug_build():
		get_parent().queue_free()

