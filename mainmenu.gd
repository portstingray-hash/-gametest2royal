extends Node2D

@onready var name_label = $name
@onready var scene_change_timer = $SceneChangeTimer

func _ready():
	initialize_player()
	if Global.selected_banner != null:
		$BannerDisplay.texture = Global.selected_banner

		
func initialize_player():
	name_label.text = Global.player_name 


func _on_texture_button_2_pressed():
	$ClickSound.play()
	$AnimationPlayer.play("loading")
	await get_tree().create_timer(8).timeout
	call_deferred("_changed_scene")	

func _on_texture_button_pressed():
	$AnimationPlayer.play("Homemenu")

func _on_scene_change_timer_timeout():
	_changed_scene()

func _changed_scene():
	get_tree().change_scene_to_file("res://gameloading.tscn")


func _on_deck_pressed():
	$AnimationPlayer.play("deck")


func _on_banner_1_pressed():
	Global.selected_banner = preload("res://assets/banner1.png")
	print("Banner 1 selected")
	$AnimationPlayer.play("Homemenu")

func _on_banner_2_pressed():
	Global.selected_banner = preload("res://assets/banner2.png")
	print("Banner 2 selected")
	$AnimationPlayer.play("Homemenu")

func _on_banner_3_pressed():
	Global.selected_banner = preload("res://assets/banner3.png")
	print("Banner 3 selected")
	$AnimationPlayer.play("Homemenu")


func _on_edit_pressed():
	get_tree().change_scene_to_file("res://banner_display.tscn")


func _on_cancel_pressed():
	scene_change_timer.stop()
	$AnimationPlayer.play("Homemenu")


