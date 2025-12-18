extends StaticBody2D

@export var max_hp: int = 1400
@export var tower_owner: String = "bot"
@export var is_king_tower: bool = false
@export var side: String = "left" 

@export var attack_damage := 100
@export var attack_speed := 1.0 # seconds between shots
@onready var attack_range = $AttackRanage
@onready var attack_timer = $AttackTimer 
@onready var timer = Timer.new()

var target = null
var current_target = null
var current_hp: int
signal tower_destroyed(tower_owner, is_king_tower)
@export var target_group := "enemy"


func _ready():
	current_hp = max_hp
	update_health_bar()
	add_to_group("enemy")

	timer.wait_time = attack_speed
	timer.one_shot = false
	timer.autostart = false
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_attack_timeout"))

	# Connect to area entered signal
	attack_range.connect("area_entered", Callable(self, "_on_area_entered"))
	attack_range.connect("area_exited", Callable(self, "_on_area_exited"))

func take_damage(amount: int):
	print("Tower took damage: ", amount)
	current_hp -= amount
	update_health_bar()

	if current_hp <= 0:
		emit_signal("tower_destroyed", tower_owner, is_king_tower)
		queue_free()

func update_health_bar():
	var bar = $HealthBar
	if bar:
		bar.value = float(current_hp) / max_hp * 100.0

func _on_body_entered(body):
	if body.is_in_group("troop"):
		if current_target == null:
			current_target = body
			timer.start()

func _on_area_entered(area):
	var body = area.get_parent()
	if body.is_in_group("knights"):
		target = body
		attack_timer.start()

func _on_area_exited(area):
	var body = area.get_parent()
	if body == target:
		target = null
		attack_timer.stop()

func _on_body_exited(body):
	if body == current_target:
		current_target = null
		timer.stop()

func _on_attack_timeout():
	if current_target and is_instance_valid(current_target):
		if current_target.has_method("take_damage"):
			current_target.take_damage(attack_damage)
	else:
		current_target = null
		timer.stop()


func _on_attack_timer_timeout():
	if target and is_instance_valid(target):
		if target.has_method("take_damage"):
			target.take_damage(50)


func _on_attack_ranage_area_entered(area):
	var parent_node = area.get_parent()
	print("Entered area of:", parent_node)

	if area.is_in_group(target_group) and parent_node and parent_node.has_method("take_damage"):
		print("Target acquired:", parent_node.name)
		target = parent_node
		$Timer.start()
