extends CharacterBody3D

@export var speed : float = 5.0
@export var doge_speed : float = 20
@export var camera: Camera3D

const DEAD_ZONE := 0.5   # jetzt in Metern (Weltraum), nicht Pixeln
const SMOOTH := 10.0

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Movement (relativ zur Kamera, nicht zum Charakter)
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3(input_dir.x, 0, input_dir.y)
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	# --- Rotation zur Maus ---
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_dir := camera.project_ray_normal(mouse_pos)

	var ground := Plane(Vector3.UP, global_position.y)
	var hit = ground.intersects_ray(ray_origin, ray_dir)

	if hit != null:
		var to_target: Vector3 = hit - global_position
		to_target.y = 0
		if to_target.length() > DEAD_ZONE:
			var target_angle := atan2(-to_target.x, -to_target.z)
			rotation.y = lerp_angle(rotation.y, target_angle, SMOOTH * delta)
