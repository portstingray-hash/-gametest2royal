extends StaticBody2D

@export var max_hp: int = 2400
@export var tower_owner: String = "Bot"
@export var is_king_tower: bool = true

var current_hp: int
signal tower_destroyed(tower_owner, is_king_tower)

func _ready():
	current_hp = max_hp
	update_health_bar()

func take_damage(amount: int):
	current_hp -= amount
	update_health_bar()

	if current_hp <= 0:
		emit_signal("tower_destroyed", tower_owner, is_king_tower)
		queue_free()

func update_health_bar():
	var bar = $HealthBar
	if bar:
		bar.value = float(current_hp) / max_hp * 100.0

