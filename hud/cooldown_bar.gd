extends Node2D

class_name CooldownBar

var is_skill_on_cooldown = false;
var cooldown_time: float;
var current_counted_time = 0;

func _ready():
	pass;
	
func init(new_cooldown_time: float):
	cooldown_time = new_cooldown_time;
	hide();

func set_bar_width_in_percent(width: float):
	var clampedWidth = clamp(width, 0, 100);
	if $Bar:
		$Bar.transform.x[0] = 1 - (clampedWidth / 100.0);

func reset():
	$Bar.transform.x[0] = 1;

func progress_time(delta: float):
	if is_skill_on_cooldown:
		current_counted_time += delta * 1000;
		set_bar_width_in_percent((current_counted_time / cooldown_time) * 100);
		print(current_counted_time / cooldown_time);
		if cooldown_time <= current_counted_time:
			is_skill_on_cooldown = false;
			current_counted_time = 0;

func start():
	show();
	is_skill_on_cooldown = true;

func finish():
	hide();
	reset();
	is_skill_on_cooldown = false;
