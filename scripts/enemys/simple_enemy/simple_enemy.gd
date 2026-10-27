class_name SimpleEnemy
extends BaseEnemy

@export var follow_speed : float = 3.0

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var state_chart : StateChart = $StateChart
@onready var animations : AnimationPlayer = $AnimationPlayer

var target : Node3D

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
	
	if nav_agent.is_navigation_finished():
		nav_agent.velocity = Vector3.ZERO
		return
	
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	
	# Fangen an zu laufen
	nav_agent.velocity = direction * follow_speed
	
	if direction.length() > 0.01:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 5.0 * delta)

func _on_idle_state_state_physics_processing(_delta: float) -> void:
	# Idle Aktion einfügen
	pass


func _on_idle_state_state_entered() -> void:
	animations.play("animations/idle_sword")


func _on_follow_state_state_entered() -> void:
	animations.play("animations/air_guitar")


func _on_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("Attack")


func _on_sight_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		on_trigger()
