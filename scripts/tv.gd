extends Node3D
## Break-room TV: EAS / DENVER METRO / snow loop.

@onready var _screen: MeshInstance3D = $Screen

var _mats: Array[StandardMaterial3D] = []
var _i: int = 0
var _t: float = 0.0
const HOLDS := [2.4, 2.1, 1.35]


func _ready() -> void:
	for path in [
		"res://textures/tv_eas_standby.png",
		"res://textures/tv_denver_metro.png",
		"res://textures/tv_snow.png",
	]:
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_texture = load(path)
		m.emission_enabled = true
		m.emission_texture = load(path)
		m.emission_energy_multiplier = 1.8
		_mats.append(m)
	_apply()


func _process(delta: float) -> void:
	_t += delta
	if _t >= HOLDS[_i]:
		_t = 0.0
		_i = (_i + 1) % _mats.size()
		_apply()


func _apply() -> void:
	if _screen:
		_screen.material_override = _mats[_i]
