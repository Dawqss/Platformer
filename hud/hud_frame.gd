extends Node2D

class_name HealthBar

var label: Label;
var health_bar: Sprite2D;
var startValue: float;

var max_health = Main.MAX_HEALTH;

func set_max_health(new_max_health: int):
	max_health = new_max_health;

func _ready():
	label = $Label;
	health_bar = $Health;
	startValue = health_bar.transform.x[0];

func set_label_value(value: String):
	label.text = value;
	label.show();
	process_label_width(value);

func process_label_width(value: String):
	var multiplier = float(value) / float(max_health);
	var new_value_x = multiplier * startValue;
	
	print(new_value_x);
	
	$Health.transform.x[0] = new_value_x;
