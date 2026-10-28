extends CharacterBody3D

@export var speed : float = 5.0
@export var dodge_speed : float = 10.0
@export var camera: Camera3D

var is_dodgeing : bool = false

##Benötigt für Rotation zur Maus
const dead_zone := 0.5

##Wie schnell sich der Character drehen soll
const smooth := 10.0

@onready var animations : AnimationPlayer = $animation_player
@onready var state_chart : StateChart = $StateChart

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("dodge_roll"):
		state_chart.send_event("toDodge")
	
	# Movement (relativ zur Kamera, nicht zum Charakter)
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3(input_dir.x, 0, input_dir.y)
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y).normalized()

	if is_dodgeing:
		if direction:
			velocity.x = direction.x * dodge_speed
			velocity.z = direction.z * dodge_speed
		else:
			velocity.x = move_toward(velocity.x, 0, dodge_speed)
			velocity.z = move_toward(velocity.z, 0, dodge_speed)
	else:
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

	if velocity != Vector3.ZERO:
		state_chart.send_event("toRun")
	else:
		state_chart.send_event("toIdle")
	
	move_and_slide()

	# --- Rotation zur Maus ---
	#var mouse_pos := get_viewport().get_mouse_position()
	#var ray_origin := camera.project_ray_origin(mouse_pos)
	#var ray_dir := camera.project_ray_normal(mouse_pos)
	
	#var ground := Plane(Vector3.UP, global_position.y)
	#var hit = ground.intersects_ray(ray_origin, ray_dir)
	
	#if hit != null:
		#var to_target: Vector3 = hit - global_position
		#to_target.y = 0
		#if to_target.length() > dead_zone:
			#var target_angle := atan2(to_target.x, to_target.z)
			#rotation.y = lerp_angle(rotation.y, target_angle, smooth * delta)
	
	# --- Rotation in Bewegungsrichtung ---
	if velocity.x != 0 or velocity.z != 0:
		var target_angle := atan2(velocity.x, velocity.z)
		rotation.y = lerp_angle(rotation.y, target_angle, smooth * delta)   


func _on_idle_state_state_entered() -> void:
	if animations.current_animation == "player_animations/dodge_roll":
		await animations.animation_finished
		is_dodgeing = false
	animations.play("player_animations/idle")

func _on_run_state_state_entered() -> void:
	if animations.current_animation == "player_animations/dodge_roll":
		await animations.animation_finished
		is_dodgeing = false
	animations.play("player_animations/slow_run")

func _on_dodge_state_state_entered() -> void:
	is_dodgeing = true
	animations.play("player_animations/dodge_roll")

func _on_idle_state_state_physics_processing(_delta: float) -> void:
	pass

func _on_run_state_state_physics_processing(_delta: float) -> void:
	pass
