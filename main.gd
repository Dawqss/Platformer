extends Node

class_name Main

const MAX_HEALTH = 100;

var current_health = MAX_HEALTH;
var healthBar: HealthBar;
var cooldownGetsuga: CooldownBar;

func _process(delta):
	cooldownGetsuga.progress_time(delta);

func _ready():
	healthBar = $Camera2D/HealthBar;
	cooldownGetsuga = $Camera2D/CooldownBar;
	cooldownGetsuga.init(Getsuga.COOLDOWN_TIME * 1000);

func add_health(number: int):
	current_health = clamp(current_health + number, 0, MAX_HEALTH);
	healthBar.set_label_value(str(current_health));
	
func remove_health(number: int):
	current_health = clamp(current_health - number, 0, MAX_HEALTH);
	healthBar.set_label_value(str(current_health));
	
func on_cooldown_change():
	pass;

func _on_player_got_hit(signal_name: SignalsNames.names, value):
	match signal_name:
		SignalsNames.names.REMOVE_HEALTH:
			remove_health(value);
	
func _on_player_hud_signal(signal_name: HudUpdate.EventNames):
	match signal_name:
		HudUpdate.EventNames.GetsugaStart:
			cooldownGetsuga.start();
		HudUpdate.EventNames.GetsugaEnd:
			cooldownGetsuga.finish()
	
