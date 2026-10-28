class_name SimpleEnemy
extends BaseEnemy

@export var follow_speed : float = 3.0
@export var search_range_size : float = 2.5

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var state_chart : StateChart = $StateChart
@onready var animations : AnimationPlayer = $animation_player

var search_range : Vector3

##Wie schnell sich der Character drehen soll
const smooth := 10.0

var target : Node3D
var last_known_position : Vector3

func _ready() -> void:
	super._ready()
	
	target = get_tree().get_first_node_in_group("player")
	
	nav_agent.velocity_computed.connect(_on_velocity_computed)

func _physics_process(delta: float) -> void:
	#Apply gravity
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	
	move_and_slide()

func on_trigger() -> void:
	state_chart.send_event("toFollow")

func _on_velocity_computed(safe_velocity : Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z

func _on_follow_state_state_physics_processing(delta: float) -> void:
	if not target:
		return
	
	nav_agent.target_position = target.global_position
	last_known_position = target.global_position
	search_range = last_known_position
	
	if nav_agent.is_navigation_finished():
		nav_agent.velocity = Vector3.ZERO
		return
	
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	
	# Fangen an zu laufen
	nav_agent.velocity = direction * follow_speed
	
	if direction.length() > 0.01:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, smooth * delta)

func _on_idle_state_state_entered() -> void:
	animations.play("enemy_animations/idle")


func _on_follow_state_state_entered() -> void:
	animations.play("enemy_animations/slow_run")


func _on_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("Attack")


func _on_sight_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		on_trigger()


func _on_sight_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		state_chart.send_event("toSearching")

func _on_search_state_state_entered() -> void:
	animations.play("enemy_animations/walking")


func _on_search_state_state_physics_processing(delta: float) -> void:
	if nav_agent.velocity != Vector3.ZERO:
		animations.play("enemy_animations/walking")
	else:
		animations.play("enemy_animations/searching")
	
	if nav_agent.target_position != Vector3.INF:
		if last_known_position <= Vector3.ONE:
			
			nav_agent.target_position = last_known_position

			if nav_agent.is_navigation_finished() or global_position.distance_to(last_known_position) < 0.01:
				nav_agent.velocity = Vector3.ZERO
				nav_agent.target_position = Vector3.INF
				return

			var next_pos = nav_agent.get_next_path_position()
			var direction = (next_pos - global_position).normalized()
			nav_agent.velocity = direction * follow_speed * 0.5  # slower during search

			var target_rotation = atan2(direction.x, direction.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, smooth * delta)
		else:
			nav_agent.velocity = Vector3.ZERO
			nav_agent.target_position = Vector3.INF
	else:
		nav_agent.target_position = random_pos_in_search_range()
		last_known_position = random_pos_in_search_range()

func random_pos_in_search_range() -> Vector3:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return Vector3(rng.randf_range(-search_range_size, search_range_size) + global_position.x, 0, rng.randf_range(-search_range_size, search_range_size) + global_position.z)
