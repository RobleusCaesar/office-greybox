extends Node3D
## Flicker fire and drift smoke on the exterior diorama.


func _process(delta: float) -> void:
	var t := Time.get_ticks_msec() * 0.001
	for c in get_children():
		if not (c is Node3D):
			continue
		var n := c as Node3D
		if n.name.begins_with("Fire"):
			var s := 1.0 + 0.12 * sin(t * 7.0 + n.position.z)
			n.scale = Vector3(s, 1.0 + 0.18 * sin(t * 5.5 + n.position.z * 0.4), s)
		elif n.name.begins_with("Smoke"):
			n.position.y = 2.6 + fposmod(t * 0.22 + n.position.z * 0.05, 1.8)
			n.rotation_degrees.z = sin(t * 0.7 + n.position.z) * 8.0
