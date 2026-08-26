extends Control
## Title card. Play loads the office. Esc releases the mouse here too.


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_quit() -> void:
	get_tree().quit()
