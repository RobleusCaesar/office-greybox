extends Node3D
## Drifting people silhouettes beyond the glass.


func _process(delta: float) -> void:
	var t := Time.get_ticks_msec() * 0.001
	for c in get_children():
		if c is Node3D:
			var n := c as Node3D
			n.position.z += sin(t * 0.25 + n.position.y) * delta * 0.18
			n.position.z = clampf(n.position.z, -6.0, 6.0)
			if n.global_position.x < 38.2:
				n.global_position.x = 38.2
