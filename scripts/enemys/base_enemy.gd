class_name BaseEnemy
extends CharacterBody3D

@export var enemy_groups : Array[String] = []

func _ready() -> void:
	for group in enemy_groups:
		add_to_group(group)

func on_trigger() -> void:
	pass
