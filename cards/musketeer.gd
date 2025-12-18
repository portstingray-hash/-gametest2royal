extends CharacterBody2D

@export var move_speed := 60
@export var healthpoint := 341
@export var damage := 90
@export var attack_speed := 2
@export var target_group := "enemy"
@export var bullet_scene: PackedScene
@export var attack_range := 120.0


var current_hp := healthpoint
var target = null

func _ready():
	add_to_group("musketeers")
	$Timer.wait_time = attack_speed
	$Timer.connect("timeout", Callable(self, "_on_attack"))
	$Timer.start()

func _physics_process(delta):
	if target and is_instance_valid(target):
		var dist = global_position.distance_to(target.global_position)
		if dist > attack_range:
			var dir = (target.global_position - global_position).normalized()
			velocity = dir * move_speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
	else:
		_find_target()


func _find_target():
	var enemies = get_tree().get_nodes_in_group(target_group)
	var closest = null
	var closest_dist = INF
	for e in enemies:
		if e and e.has_method("take_damage"):
			var dist = global_position.distance_to(e.global_position)
			if dist < closest_dist:
				closest = e
				closest_dist = dist
	target = closest

func _on_attack():
	if target and is_instance_valid(target):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = (target.global_position - global_position).normalized()
		bullet.damage = damage
		bullet.target_group = target_group
		get_tree().current_scene.add_child(bullet)

func take_damage(amount):
	current_hp -= amount
	$Label.text = str(current_hp)
	if current_hp <= 0:
		queue_free()
