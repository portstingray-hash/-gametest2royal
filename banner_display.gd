extends Node2D


func _on_banner_1_pressed():
	Global.selected_banner = preload("res://assets/banner1.png")
	get_tree().change_scene_to_file("res://mainmenu.tscn")

func _on_banner_2_pressed():
	Global.selected_banner = preload("res://assets/banner2.png")
	get_tree().change_scene_to_file("res://mainmenu.tscn")

func _on_banner_3_pressed():
	Global.selected_banner = preload("res://assets/banner3.png")
	get_tree().change_scene_to_file("res://mainmenu.tscn")


func _on_banner_4_pressed():
	Global.selected_banner = preload("res://assets/banner4.png")
	get_tree().change_scene_to_file("res://mainmenu.tscn")
