extends CharacterBody3D

@export var speed : float = 5.0
@export var dodge_speed : float = 10.0
@export var dodge_imortal : float = 0.5
@export var dodge_cooldown : float = 0.5
@export var camera: Camera3D
@export var rotation_to_mouse : bool = false

var is_dodgeing : bool = false
var can_dodge : bool = true

var is_imortal : bool = false

##Benötigt für Rotation zur Maus
const dead_zone := 0.5

##Wie schnell sich der Character drehen soll
const smooth := 10.0

@onready var animations : AnimationPlayer = $AnimationPlayer
@onready var state_chart : StateChart = $StateChart
@onready var attack_timer : Timer = $attack_timer

###Ob ein zweiter Angriff ausgeführt werden soll
var second_attack : bool = false

func _physics_process(delta):
	if not is_imortal:
		#print("Not Imortal")
		pass
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("dodge_roll") and can_dodge:
		state_chart.send_event("toDodge")
	
	if Input.is_action_just_pressed("attack"):
		state_chart.send_event("toAttack")
	
	if second_attack == true:
		state_chart.send_event("toAttack")
	
	# Movement (relativ zur Kamera, nicht zum Charakter)
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3(input_dir.x, 0, input_dir.y)
	direction = direction.rotated(Vector3.UP, camera.global_rotation.y).normalized()

	if is_dodgeing:
		var dodge_direction = transform.basis.z.normalized()
		velocity = dodge_direction * dodge_speed
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

	if rotation_to_mouse:
		# --- Rotation zur Maus ---
		var mouse_pos := get_viewport().get_mouse_position()
		var ray_origin := camera.project_ray_origin(mouse_pos)
		var ray_dir := camera.project_ray_normal(mouse_pos)
		
		var ground := Plane(Vector3.UP, global_position.y)
		var hit = ground.intersects_ray(ray_origin, ray_dir)
		
		if hit != null:
			var to_target: Vector3 = hit - global_position
			to_target.y = 0
			if to_target.length() > dead_zone:
				var target_angle := atan2(to_target.x, to_target.z)
				rotation.y = lerp_angle(rotation.y, target_angle, smooth * delta)
	else:
		# --- Rotation in Bewegungsrichtung ---
		if velocity.x != 0 or velocity.z != 0:
			var target_angle := atan2(velocity.x, velocity.z)
			rotation.y = lerp_angle(rotation.y, target_angle, smooth * delta)   


func _on_idle_state_state_entered() -> void:
	if is_dodgeing:
		return
	if animations.current_animation == "charon_schwert_angriff_01" or animations.current_animation == "charon_schwert_angriff_02":
		return
	animations.play("charon_stehen_idle_01")

func _on_run_state_state_entered() -> void:
	if is_dodgeing:
		return
	animations.play("charon_laufen_01")

func _on_dodge_state_state_entered() -> void:
	is_dodgeing = true
	can_dodge = false
	
	animations.play("charon_dodge_01")
	
	var dodge_duration : float = 1.0
	is_imortal = true
	await get_tree().create_timer(dodge_duration).timeout
	
	is_dodgeing = false
	is_imortal = false
	
	await  get_tree().create_timer(dodge_cooldown).timeout
	can_dodge = true
	
	state_chart.send_event("toIdle")

func _on_idle_state_state_physics_processing(_delta: float) -> void:
	pass

func _on_run_state_state_physics_processing(_delta: float) -> void:
	pass

func _on_attack_state_state_entered() -> void:
	if second_attack == true:
		if animations.current_animation_position >= 1.0:
			animations.play("charon_schwert_angriff_02")
			second_attack = false
	elif animations.current_animation == "charon_schwert_angriff_01":
		if animations.current_animation_position >= 0.1 and animations.current_animation_position <= 0.95:
			second_attack = true
	else:
		if animations.current_animation == "charon_schwert_angriff_02":
			await animations.animation_finished
		animations.play("charon_schwert_angriff_01")
	
	
