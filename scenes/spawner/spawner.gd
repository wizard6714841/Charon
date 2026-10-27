extends Marker3D

@export var enemys : Array[PackedScene] = []
@export var enemys_spawn_chance : Array[int] = []
@export var spawn_enemys_at_start : bool = false
@export var spawn_reste_time : float = 3.0
@export var one_time_spawn : bool = true

var player_in_spawner_range : bool = false
var can_spawn : bool = true

@onready var timer_ref : Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer_ref.wait_time = spawn_reste_time
	if spawn_enemys_at_start:
		spawn()

func _on_activation_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_spawner_range = true
		spawn()

func _on_activation_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_spawner_range = false

func _on_timer_timeout() -> void:
	can_spawn = true

func spawn() -> void:
	if can_spawn:
		var enemy_instance
		if enemys.size() == 1:
			enemy_instance = enemys[0].instantiate()
		else:
			enemy_instance = enemys[random_enemy()].instantiate()
		add_child(enemy_instance)
	
	if one_time_spawn:
		can_spawn = false
	elif spawn_enemys_at_start:
		can_spawn = false
		spawn_enemys_at_start = false
	elif timer_ref.is_stopped():
		timer_ref.start()
		can_spawn = false

func random_enemy():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var weighted_sum : int = 0
	
	for n in range(enemys.size()):
		weighted_sum += enemys_spawn_chance[n]
	
	var enemy_to_spawn = rng.randi_range(0, weighted_sum)
	
	for n in range(enemys.size()):
		if enemy_to_spawn <= enemys_spawn_chance[n]:
			return n
		enemy_to_spawn -= enemys_spawn_chance[n]
	
