extends Node

class_name Main

const MAX_HEALTH = 100;

var current_health = MAX_HEALTH;
var healthBar: HealthBar;

func _ready():
	healthBar = $Camera2D/HealthBar;

func add_health(number: int):
	current_health = clamp(current_health + number, 0, MAX_HEALTH);
	healthBar.set_label_value(str(current_health));
	
func remove_health(number: int):
	current_health = clamp(current_health - number, 0, MAX_HEALTH);
	healthBar.set_label_value(str(current_health));

func _on_player_got_hit(signal_name: SignalsNames.names, value):
	match signal_name:
		SignalsNames.names.REMOVE_HEALTH:
			remove_health(value);
	
