extends Node2D

#Game Time
@onready var label = $Sprite2D/Countdown
@onready var timer = $Timer

#Music
@onready var mainmusic = $Music/MainMusic
@onready var reminder = $Music/"Timer Reminder"
@onready var oneminute = $Music/"30sec-1"
@onready var final30 = $Music/final30
@onready var countdown = $Music/coutdown
@onready var OvertimeLabel = $CanvasLayer/OvertimeLabel
@onready var overtime_music = $Music/overtime
@onready var overtimesound = $Music/Overtimesound

@onready var no_place_area = $NoPlaceArea
@onready var poly_node = $NoPlaceArea/CollisionPolygon2D
@onready var no_place_shape = no_place_area.get_node("CollisionPolygon2D")

@onready var knight_scene = preload("res://cards/knight.tscn")
@onready var spawn_layer = $spawn_layer

#Emote
@onready var emote_scene = preload("res://king_emote.tscn")
@onready var emote_layer = $EmoteLayer
@onready var emote_button = $EmoteLayer/EmoteButton

#Knight Info
@onready var knight_cooldown = $controlspawn/knightcooldown
var can_spawn_knight := true
var knight_cost := 3
const KNIGHT_COST = 3

#MiniPekka Info
@onready var minipekka_scene = preload("res://cards/minipekka.tscn")
@onready var minipekka_cooldown = $controlspawn/minipekkacooldown
var can_spawn_minipekka := true
const MINIPEKKA_COST := 4

#Giant
@onready var giant_scene = preload("res://cards/giant.tscn")
@onready var giant_cooldown = $controlspawn/giantcooldown
var can_spawn_giant := true
const GIANT_COST := 5

#musketeer
@onready var musketeer_scene = preload("res://cards/musketeer.tscn")
@onready var musketeer_cooldown = $controlspawn/musketeercooldown
var can_spawn_musketeer := true
const MUSKETEER_COST := 4

#Archers
@onready var archers_scene = preload("res://cards/archers.tscn")
@onready var archers_cooldown = $controlspawn/archerscooldown
var can_spawn_archers := true
const ARCHERS_COST := 3

#Minion
@onready var minion_scene = preload("res://cards/minions.tscn")
@onready var minion_cooldown = $controlspawn/minioncooldown
var can_spawn_minion := true
const MINION_COST := 3

#Arrow
@onready var arrow_scene = preload("res://cards/arrows.tscn")
@onready var arrow_cooldown = $controlspawn/arrowcooldown
var can_spawn_arrow := true
const ARROWS_COST := 3

#fireball
@onready var fireball_scene = preload("res://cards/fireball.tscn")
@onready var fireball_cooldown = $controlspawn/fireballcooldown
var can_spawn_fireball := true
const FIREBALL_COST := 4

#player info
@onready var name_label = $playername/player_name

#Info i guess
var player_crowns = 0
var bot_crowns = 0
var in_overtime = false
var game_over = false
var card

#Elixir Info
var elixir := 2
var max_elixir := 10
var elixir_gain_rate := 0.5  # per second
var elixir_timer := 5.0


var card_button_scene = preload("res://CardButton.tscn")



func spawn_knight():
	var knight = knight_scene.instantiate()
	spawn_layer.add_child(knight)
	knight.global_position = Vector2(500, 500)
	print("Knight has been spawned")

var music_triggers = [
	{
		"start_time": 120,
		"stop_time": 60,
		"has_stop_time": true,
		"player": null,
		"playing": false
	},
	{
		"start_time": 61,
		"has_stop_time": false,
		"player": null,
		"playing": false
	},
	{
		"start_time": 60,
		"stop_time": 30,
		"has_stop_time": true,
		"player": null,
		"playing": false
	},
	{
		"start_time": 31,
		"has_stop_time": false,
		"player": null,
		"playing": false
	},
	{
		"start_time": 30,
		"stop_time": 9,
		"has_stop_time": true,
		"player": null,
		"playing": false
	},
	{
		"start_time": 11,
		"stop_time": 0,
		"has_stop_time": true,
		"player": null,
		"playing": false
	},
]

var overtime_triggers = []  

func start_overtime():
	in_overtime = true
	timer.stop()
	timer.wait_time = 90  
	timer.start()

	mainmusic.stop()
	reminder.stop()
	oneminute.stop()
	final30.stop()
	countdown.stop()

	overtime_music.play()
	OvertimeLabel.visible = true

	print("Overtime started!")
	$AnimationPlayer.play("overtime-notif")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("overtime")

func initialize_player():
	name_label.text = Global.player_name

func _ready():
	initialize_player()
	var music = get_node_or_null("/root/cr-music")
	if music:
		music.queue_free()	


	if OvertimeLabel:
		OvertimeLabel.visible = false
	print("OvertimeLabel is: ", OvertimeLabel)
	timer.wait_time = 123  
	timer.start()


	var player_king_tower = $"Blue-tower/Kingtower"
	player_king_tower.connect("tower_destroyed", Callable(self, "_on_tower_destroyed"))

	var bot_king_tower = $"Red-Tower/RedKingtower"
	bot_king_tower.connect("tower_destroyed", Callable(self, "_on_tower_destroyed"))

	var player_princess_tower1 = $"Blue-tower/PrincessTower"
	player_princess_tower1.connect("tower_destroyed", Callable(self, "_on_tower_destroyed"))

	var bot_princess_tower1 = $"Red-Tower/RedPrincessTower"
	bot_princess_tower1.connect("tower_destroyed", Callable(self, "_on_tower_destroyed"))


	music_triggers[0]["player"] = mainmusic
	music_triggers[1]["player"] = reminder
	music_triggers[2]["player"] = oneminute
	music_triggers[3]["player"] = reminder
	music_triggers[4]["player"] = final30
	music_triggers[5]["player"] = countdown


	overtime_triggers = [
		{ "time": 91, "played": false, "player": overtimesound },
		{ "time": 61, "played": false, "player": reminder },
		{ "time": 31, "played": false, "player": reminder },
		{ "time": 11, "played": false, "player": countdown },
	]

	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))


func _on_Timer_timeout():
	if game_over:
		get_tree().quit()

	if not in_overtime:
		if player_crowns == bot_crowns:
			start_overtime()
		else:
			var winner = "player" if player_crowns > bot_crowns else "bot"
			end_game(winner)
	else:
		if player_crowns == bot_crowns:
			end_game("draw")
		else:
			var winner = "player" if player_crowns > bot_crowns else "bot"
			end_game(winner)

func time_left_to_live():
	var time_left = timer.time_left
	var minute = floor(time_left / 60)
	var second = int(time_left) % 60
	return [minute, second]



func _process(_delta):
	elixir_timer += _delta
	if elixir_timer >= 1.0:
		if elixir < max_elixir:
			elixir += 1
			update_elixir_ui()
		elixir_timer = 0.0
	label.text = "%02d:%02d" % time_left_to_live()

	for trigger in music_triggers:
		if in_overtime:
			break  # Don't run regular game sounds in overtime

		if trigger["player"] == null:
			continue

		if not trigger["playing"] and timer.time_left <= trigger["start_time"]:
			trigger["player"].play()
			trigger["playing"] = true

		if trigger.get("has_stop_time", false) and trigger["playing"] and timer.time_left <= trigger.get("stop_time", 0):
			trigger["player"].stop()
			trigger["playing"] = false


	if in_overtime:
		for trigger in overtime_triggers:
			if not trigger["played"] and timer.time_left <= trigger["time"]:
				trigger["player"].play()
				trigger["played"] = true

func _on_tower_destroyed(tower_owner, is_king_tower):
	print("Tower destroyed by: ", tower_owner, " Is king tower: ", is_king_tower)

	if is_king_tower:
		var winner = "bot" if tower_owner == "player" else "player"
		end_game(winner)
		return

	update_crown_score(tower_owner)

	if in_overtime:
		var winner = "player" if tower_owner == "bot" else "bot"
		end_game(winner)

func end_game(winner):
	if game_over:
		return

	game_over = true
	print("Game Over! Winner: " + winner)

	timer.stop()

	mainmusic.stop()
	reminder.stop()
	oneminute.stop()
	final30.stop()
	countdown.stop()
	OvertimeLabel.visible = false

	await get_tree().create_timer(4.0).timeout  # optional delay for animations

	if winner == "Player":
		get_tree().change_scene_to_file("res://player_win.tscn")
	elif winner == "Bot":
		get_tree().change_scene_to_file("res://player_loss.tscn")
	else:
		get_tree().change_scene_to_file("res://draw_scene.tscn")  # optional

func update_crown_score(tower_owner):
	print(tower_owner + " lost a tower!")
	if tower_owner == "bot":
		player_crowns += 1
	elif tower_owner == "player":
		bot_crowns += 1
	print("Crowns — Player:", player_crowns, "Bot:", bot_crowns)


func knight_spawn(pos):
	if not can_spawn_knight:
		print("Knight on cooldown")
		return
	
	var instance = knight_scene.instantiate()
	instance.position = pos
	add_child(instance)
	
	can_spawn_knight = false
	knight_cooldown.start()

func _physics_process(_delta):
	if Input.is_action_just_pressed("MOUSE_BUTTON_LEFT"):
		var mouse_pos = get_global_mouse_position()
		
		if Input.is_key_pressed(KEY_1):
			# Knight
			print("key 1 has been pressed")
			if not can_spawn_knight or elixir < KNIGHT_COST or not can_place_at_position(mouse_pos):
				print("Knight can't spawn")
				return
			elixir -= KNIGHT_COST
			knight_spawn(mouse_pos)
			update_elixir_ui()

		elif Input.is_key_pressed(KEY_2):
			# Minipekka
			print("key 2 has been pressed")
			if not can_spawn_minipekka or elixir < MINIPEKKA_COST or not can_place_at_position(mouse_pos):
				print("Mini P.E.K.K.A. can't spawn")
				return
			elixir -= MINIPEKKA_COST
			minipekka_spawn(mouse_pos)
			update_elixir_ui()


		elif Input.is_key_pressed(KEY_3):
			# Giant
			print("key 3 has been pressed")
			if not can_spawn_giant or elixir < GIANT_COST or not can_place_at_position(mouse_pos):
				print("Giant can't spawn")
				return
			elixir -= GIANT_COST
			spawn_giant(mouse_pos)
			update_elixir_ui()

		elif Input.is_key_pressed(KEY_4):
			# Musketeer
			print("key 4 has been pressed")
			if not can_spawn_musketeer or elixir < MUSKETEER_COST or not can_place_at_position(mouse_pos):
				print("Giant can't spawn")
				return
			elixir -= MUSKETEER_COST
			spawn_musketeer(mouse_pos)
			update_elixir_ui()

		elif Input.is_key_pressed(KEY_5):
			# Archer
			print("key 5 has been pressed")
			if not can_spawn_archers or elixir < ARCHERS_COST or not can_place_at_position(mouse_pos):
				print("Archer can't spawn")
				return
			elixir -= ARCHERS_COST
			spawn_archers(mouse_pos)
			update_elixir_ui()
			
		elif Input.is_key_pressed(KEY_6):
			# Minion
			print("key 6 has been pressed")
			if not can_spawn_minion or elixir < MINION_COST or not can_place_at_position(mouse_pos):
				print("Minion can't spawn")
				return
			elixir -= MINION_COST
			spawn_minion(mouse_pos)
			update_elixir_ui()

		elif Input.is_key_pressed(KEY_7):
			# Arrow
			print("key 7 has been pressed")
			if not can_spawn_arrow or elixir < ARROWS_COST or not can_place_at_position(mouse_pos):
				print("Arrow can't spawn")
				return
			elixir -= ARROWS_COST
			spawn_arrow(mouse_pos)
			update_elixir_ui()

		elif Input.is_key_pressed(KEY_8):
			# Fireball
			print("key 8 has been pressed")
			if not can_spawn_fireball or elixir < FIREBALL_COST or not can_place_at_position(mouse_pos):
				print("Fireball can't spawn")
				return
			elixir -= FIREBALL_COST
			spawn_fireball(mouse_pos)
			update_elixir_ui()

func _on_knightcooldown_timeout():
	can_spawn_knight = true
	print("Knight cooldown finished, ready to spawn again")

#Minipekka

func minipekka_spawn(pos: Vector2):
	if not can_spawn_minipekka:
		print("Mini P.E.K.K.A. on cooldown")
		return

	var instance = minipekka_scene.instantiate()
	instance.position = pos
	add_child(instance)

	can_spawn_minipekka = false
	minipekka_cooldown.start()

func _on_minipekkacooldown_timeout():
	can_spawn_minipekka = true
	print("Mini P.E.K.K.A. cooldown finished")

#Giant
func spawn_giant(pos: Vector2):
	if not can_spawn_giant:
		print("Giant on cooldown")
		return

	var instance = giant_scene.instantiate()
	instance.position = pos
	add_child(instance)

	can_spawn_giant = false
	giant_cooldown.start()


func _on_giantcooldown_timeout():
	can_spawn_minipekka = true
	print("Giant cooldown finished")

#Musketeer
func spawn_musketeer(pos: Vector2):
	if not can_spawn_musketeer:
		print("Giant on cooldown")
		return

	var instance = musketeer_scene.instantiate()
	instance.position = pos
	add_child(instance)

	can_spawn_musketeer = false
	musketeer_cooldown.start()


func _on_musketeercooldown_timeout():
	can_spawn_minipekka = true
	print("Musketeer cooldown finished")

#Archers
func spawn_archers(pos: Vector2):
	if not can_spawn_archers:
		print("Archer on cooldown")
		return

	var instance = archers_scene.instantiate()
	instance.position = pos
	add_child(instance)

	can_spawn_archers = false
	archers_cooldown.start()

func _on_archerscooldown_timeout():
	can_spawn_minipekka = true
	print("Musketeer cooldown finished")

#Minion
func spawn_minion(pos: Vector2):
	if not can_spawn_minion:
		print("Minion on cooldown")
		return

	var instance = minion_scene.instantiate()
	instance.position = pos
	add_child(instance)

	can_spawn_minion = false
	archers_cooldown.start()

func _on_minioncooldown_timeout():
	can_spawn_minion = true
	print("Minion cooldown finished")

#Arrow
func spawn_arrow(pos: Vector2):
	if not can_spawn_arrow:
		print("Arrows on cooldown")
		return

	var instance = arrow_scene.instantiate()
	instance.position = pos
	add_child(instance)

	can_spawn_arrow = false
	arrow_cooldown.start()
	
func _on_arrowcooldown_timeout():
	can_spawn_arrow = true
	print("Arrow cooldown finished")

#Fireball
func spawn_fireball(pos: Vector2):
	if not can_spawn_fireball:
		print("Fireball on cooldown")
		return

	var instance = fireball_scene.instantiate()
	instance.position = pos
	add_child(instance)

	can_spawn_fireball = false
	fireball_cooldown.start()

func _on_fireballcooldown_timeout():
	can_spawn_fireball = true
	print("Fireball cooldown finished")

#elix	
func update_elixir_ui():
	$ElixirUI/ElixirBar.value = elixir
	$ElixirUI/ElixirLabel.text = str(elixir)



#Emote

var can_use_emote := true
var emote_cooldown := 3.0 

func _on_emote_button_pressed():
	if not can_use_emote:
		print("Emote on cooldown")
		return
		
	can_use_emote = false
	
	var emote = emote_scene.instantiate()
	emote_layer.add_child(emote)

	await get_tree().create_timer(2.5).timeout
	emote.queue_free()

	await get_tree().create_timer(emote_cooldown).timeout
	can_use_emote = true


func can_place_at_position(pos: Vector2) -> bool:
	var poly_node: CollisionPolygon2D = no_place_area.get_node("CollisionPolygon2D")
	var polygon: PackedVector2Array = poly_node.polygon
	var global_polygon: Array[Vector2] = []

	for point in polygon:
		global_polygon.append(poly_node.to_global(point))

	return not Geometry2D.is_point_in_polygon(pos, global_polygon)
