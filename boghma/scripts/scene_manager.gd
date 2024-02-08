class_name ScenesManager extends Node

signal scene_changed

@export var agent:Node

var current_scene:Node

func set_current_scene(scene:PackedScene):
	if current_scene:
		if current_scene.has_method("scene_change_exit"):
			current_scene.scene_change_exit()
		else:
			agent.remove_child(current_scene)
			current_scene.queue_free()
	
	current_scene = scene.instantiate()
	agent.add_child(current_scene)
	if current_scene.has_method("scene_change_enter"):
		current_scene.scene_change_enter()
	scene_changed.emit()
	return current_scene

