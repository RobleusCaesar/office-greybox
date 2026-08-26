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
	_center_backdrop_pivot()
	resized.connect(_center_backdrop_pivot)


func _center_backdrop_pivot() -> void:
	if backdrop:
		backdrop.pivot_offset = backdrop.size * 0.5


func _process(_delta: float) -> void:
	var t := Time.get_ticks_msec() * 0.001
	var s := 1.0 + 0.02 * (1.0 + sin(t * TAU / 28.0))
	backdrop.scale = Vector2(s, s)


func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_quit() -> void:
	get_tree().quit()
