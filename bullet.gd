extends Area2D

@export var speed := 300
@export var damage := 90
var direction := Vector2.ZERO
var target_group := "enemy"

func _ready():
	$CollisionShape2D.set_deferred("disabled", false)
	connect("area_entered", Callable(self, "_on_area_entered"))

func _physics_process(delta):
	position += direction * speed * delta

func _on_area_entered(area):
	if area.is_in_group(target_group) and area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()
