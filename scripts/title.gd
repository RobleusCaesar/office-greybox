extends Control

@onready var play_btn: Button = %Play
@onready var quit_btn: Button = %Quit
@onready var backdrop: TextureRect = %Backdrop


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	play_btn.pressed.connect(_on_play)
	quit_btn.pressed.connect(_on_quit)
	play_btn.grab_focus()
	clip_contents = true
	if backdrop:
		backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED


func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_quit() -> void:
	get_tree().quit()
