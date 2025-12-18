extends Node

var music_playing := false

func _ready():
	var current_scene = get_tree().current_scene
	if not current_scene:
		return
	
	var scene_name = current_scene.name.to_lower()
	
	# Scenes where music SHOULD play
	var allowed_scenes = ["mainmenu", "deck", "gameloading"]
	
	# Scenes where music should NOT play (optional for clarity)
	var disallowed_scenes = ["logo_1", "disclaimer", "name"]

	var music = get_node_or_null("Music")
	if not music:
		print("Music node not found!")
		return

	if scene_name in allowed_scenes:
		if not music_playing:
			music.stream = preload("res://cr-music/menumusic.ogg")  # Your music path here
			music.play()
			music_playing = true
	else:
		# Stop music on all other scenes (including those before mainmenu)
		if music_playing:
			music.stop()
			music_playing = false
