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
	# Unlock Web Audio on the Play gesture so the level haunt bed can start.
	var stream: AudioStream = null
	if FileAccess.file_exists("res://audio/under_broken_steel.mp3"):
		stream = load("res://audio/under_broken_steel.mp3")
	if stream == null and FileAccess.file_exists("res://audio/haunt_bed.wav"):
		stream = load("res://audio/haunt_bed.wav")
	if stream:
		var unlock := AudioStreamPlayer.new()
		unlock.stream = stream
		unlock.volume_db = -80.0
		unlock.bus = "Master"
		add_child(unlock)
		unlock.play()
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_quit() -> void:
	get_tree().quit()
