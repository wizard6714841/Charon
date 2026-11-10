@tool
extends Node3D
class_name HealthComponent

## Referenz zur Hit Box
@export var hit_box : Area3D
## Referenz zur Hurt Box
@export var hurt_box : Area3D

## Maximale Leben
@export var max_health : float = 100:
	set(value):
		max_health = value
		update_configuration_warnings()
## Leben
@export var health : float = 100:
	set(value):
		health = value
		update_configuration_warnings()

## Schadens Wert
@export var damage : float = 0:
	set(value):
		damage = value
		update_configuration_warnings()

## Warnung ausgeben falls @export nicht gesetzt wird oder falsch gesetzt wird
func _get_configuration_warnings() -> PackedStringArray:
	## Warnung das die Area3D Fehlen
	if (hit_box == null) or (hurt_box == null):
		return ["hit_box oder hurt_box ist nicht gesetzt!"]
	
	## Warnung für falsche Namen
	if (hit_box.name != "HitBox"):
		return ["die Area3D hat nicht den namen HitBox"]
	if (hurt_box.name != "HurtBox"):
		return ["die Area3D hat nicht den namen HurtBox"]
	
	## Warnung für nicht verbundene Signale
	if hit_box.get_signal_connection_list("body_entered") == []:
		return ["das signal 'body_entered' von HitBox hat keine Verbindung!"]
	if hurt_box.get_signal_connection_list("body_entered") == []:
		return ["das signal 'body_entered' von HurtBox hat keine Verbindung!"]
	
	## Warnung für falsch verbundenes Signal
	if hit_box.get_signal_connection_list("body_entered")[0]["callable"].get_object() != self:
		return ["das signal 'body_entered' von HitBox ist nicht mit 'HealthComponent' verbunden"]
	if hurt_box.get_signal_connection_list("body_entered")[0]["callable"].get_object() != self:
		return ["das signal 'body_entered' von HurtBox ist nicht mit 'HealthComponent' verbunden"]
	
	## Warnung für falsche Werte
	if max_health < 1:
		return ["max health darf nicht kleiner 1 sein!"]
	if health > max_health:
		return ["die health kann nicht größer die wie max_health sein"]
	if damage < 0:
		return ["damage darf nicht negativ sein!"]
	return []

# Setter
## Setzte Leben
func _set_max_health(value : float) -> void:
	if value < 1:
		print("ERROR, max_health muss größer 0 sein!")
	else:
		max_health = value
## Setzte Leben
func _set_health(value : float) -> void:
	if value < 1:
		print("ERROR, health muss größer 0 sein!")
	else:
		health = value
## Setzte Schaden
func _set_damage(value : float) -> void:
	if value < 0:
		print("ERROR, damage muss größer 0 sein!")
	else:
		damage = value

# Getter
## Hole Maximales Leben
func _get_max_health() -> float:
	return max_health
## Hole Leben
func _get_health() -> float:
	return health
## Hole Schaden
func _get_damage() -> float:
	return damage

## Schaden machen
func _deal_damage() -> float:
	return _get_damage()

## Schaden bekommen
func _receive_damage(value : float) -> void:
	_set_health(_get_health() - value)

func _on_hit_box_body_entered(body: Node3D) -> void:
	if not body.is_in_group("weapon"):
		return
	else:
		if (_get_health() - _get_damage()) > 0:
			_receive_damage(_get_damage())
			print(_get_health())

func _on_hurt_box_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	else:
		_deal_damage()
