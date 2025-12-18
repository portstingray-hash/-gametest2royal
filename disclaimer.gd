extends Node2D

func _ready():
	await get_tree().create_timer(5).timeout
	call_deferred("_changed_scene")
	
func _changed_scene():
	get_tree().change_scene_to_file("res://tips.tscn")
