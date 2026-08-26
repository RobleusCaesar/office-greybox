extends Area3D
## E to take ammo. Mesh disappears.

@export var shotgun_shells: int = 4
@export var pistol_rounds: int = 12

var taken: bool = false


func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	monitoring = true
	add_to_group("ammo_pickup")


func try_pickup(player: Node) -> bool:
	if taken:
		return false
	taken = true
	if player.has_method("add_ammo"):
		player.add_ammo(shotgun_shells, pistol_rounds)
	visible = false
	monitorable = false
	monitoring = false
	queue_free()
	return true
