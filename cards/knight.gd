extends CharacterBody2D

@export var move_speed := 100
@export var healthpoint := 690
@export var damage := 79
@export var attack_speed := 1.2
@export var target_group := "enemy"

var current_hp := healthpoint
var target = null


func _ready():
	add_to_group("knights")
	await get_tree().create_timer(0.1).timeout
	_update_target_initial()

	# Connect to tower_destroyed signals on all enemy towers
	for tower in get_tree().get_nodes_in_group("enemy_tower"):
		if tower.has_signal("tower_destroyed"):
			tower.connect("tower_destroyed", Callable(self, "_on_red_tower_destroyed"))


func _update_target_initial():
	var princess_towers = []
	var king_tower = null

	for node in get_tree().get_nodes_in_group("enemy_tower"):
		if "princess" in node.name.to_lower():
			princess_towers.append(node)
		elif "king" in node.name.to_lower():
			king_tower = node

	if princess_towers.size() > 0:
		princess_towers.sort_custom(Callable(self, "_sort_by_distance"))
		target = princess_towers[0]
	elif king_tower:
		target = king_tower
	else:
		target = null

func _sort_by_distance(a, b):
	var dist_a = position.distance_to(a.position)
	var dist_b = position.distance_to(b.position)
	return dist_a - dist_b

func update_target():
	# Called when a tower is destroyed, re-pick target
	_update_target_initial()

func _physics_process(_delta):
	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _on_attack_range_area_entered(area):
	if not area:
		return

	var parent_node = area.get_parent()

	if parent_node and parent_node.is_in_group(target_group) and parent_node.has_method("take_damage"):
		print("Target acquired:", parent_node.name)
		target = parent_node
		$Timer.start()

	print("Entered area of:", parent_node)

	if parent_node and parent_node.is_in_group(target_group) and parent_node.has_method("take_damage"):
		print("Target acquired:", parent_node.name)
		target = parent_node
		$Timer.start()
			
func _on_timer_timeout():
	if target and is_instance_valid(target):
		if target.has_method("take_damage"):
			target.take_damage(damage)
		else:
			print("Target has no take_damage method")
	else:
		print("No valid target to attack")

func take_damage(amount):
	current_hp -= amount
	print("knight taking damage")
	if current_hp <= 0:
		queue_free()

func _on_red_tower_destroyed(tower_owner, is_king_tower):
	if tower_owner == "bot":
		print("A red tower was destroyed!")
		for knight in get_tree().get_nodes_in_group("knights"):
			knight.update_target()
