extends Node2D

var player_name = ""
@onready var name_box = $ColorRect/Label/TextEdit



func _on_text_edit_text_changed():
	player_name = name_box.text


func _on_confirmbutton_pressed():
	Global.player_name = player_name
	get_tree().change_scene_to_file("res://mainmenu.tscn")
