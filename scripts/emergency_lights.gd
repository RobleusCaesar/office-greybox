extends Node3D
## Pulsing red emergency lights.


func _process(_delta: float) -> void:
	var pulse := 0.55 + 0.45 * sin(Time.get_ticks_msec() * 0.004)
	for c in get_children():
		if c is OmniLight3D:
			(c as OmniLight3D).light_energy = 0.6 + pulse * 1.8
