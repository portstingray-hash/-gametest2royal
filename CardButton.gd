extends Control

signal card_dropped(position: Vector2, card_data: Dictionary)

var card_data: Dictionary = {}

var dragging := false
var drag_offset := Vector2.ZERO

func _ready():
	if card_data.has("name"):
		if has_node("CardLabel"):
			$CardLabel.text = card_data["name"]
		else:
			print("Warning: CardLabel node missing")
	if card_data.has("texture"):
		if has_node("ColorRect"):
			$ColorRect.texture = card_data["texture"]
		else:
			print("Warning: ColorRect node missing")


func _gui_input(event):
	print("Input received")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("")
			dragging = true
			drag_offset = get_global_mouse_position() - global_position
			self.set_z_index(1000)  # bring to front while dragging
		else:
			dragging = false
			emit_signal("card_dropped", global_position, card_data)
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset
