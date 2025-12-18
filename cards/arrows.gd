extends Area2D

@export var damage := 50
@onready var timer = $Timer

func _ready():
	$Timer.start()
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _on_timer_timeout():
	queue_free()
