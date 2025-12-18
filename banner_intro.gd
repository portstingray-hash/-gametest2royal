extends Node2D

@onready var name_label = $BannerDisplay/name

func _ready():
	initialize_player()
	if Global.selected_banner != null:
		$BannerDisplay.texture = Global.selected_banner
	await get_tree().create_timer(4).timeout
	call_deferred("_changed_scene")

func initialize_player():
	name_label.text = Global.player_name 

func _changed_scene():
	queue_free()
