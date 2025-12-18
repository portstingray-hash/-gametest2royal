extends Node2D
@onready var loading_bar = $loading
var load_duration := 6.0 
var elapsed_time := 0.0



var tips = [
	"Fact: You probably have a chance of winning",
	"Fact: This game is filled with bugs",
	"Tip: Try to avoid placing your troop next to your tower",
	"Tip: Just enjoy the game",
	"Tip: Place a tank then a win condition"
]

func _ready():
	loading_bar.min_value = 0
	loading_bar.max_value = 100
	loading_bar.value = 0
	
	var tip_label = $Tips
	if tip_label:
		tip_label.text = tips[randi() % tips.size()]
		
	await get_tree().create_timer(8).timeout
	call_deferred("_changed_scene")
	
func _changed_scene():
	get_tree().change_scene_to_file("res://name.tscn")


func _process(delta):
	if elapsed_time < load_duration:
		elapsed_time += delta
		var progress = clamp(elapsed_time / load_duration, 0.0, 1.0)
		loading_bar.value = progress * loading_bar.max_value
