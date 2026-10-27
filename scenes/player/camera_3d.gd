extends Camera3D

@export var player : CharacterBody3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position.x = player.position.x - 2
	position.z = player.position.z + 2
