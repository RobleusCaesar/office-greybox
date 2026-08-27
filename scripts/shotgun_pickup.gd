extends Area3D
## E to take the world shotgun. Mesh + halo disappear.

var taken: bool = false


func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	monitoring = true
	add_to_group("weapon_pickup")


func try_pickup(player: Node) -> bool:
	if taken:
		return false
	taken = true
	if player.has_method("give_shotgun"):
		player.give_shotgun()
	visible = false
	monitorable = false
	monitoring = false
	queue_free()
	return true
