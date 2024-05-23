extends Area2D

class_name Getsuga

var SPEED = 500;
var DAMAGE = 9999;

const COOLDOWN_TIME = 5;

var direction = 1;

func _ready():
	$AnimatedSprite2D.play("default");
	$AnimatedSprite2D.flip_h = bool(direction - 1);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += delta * SPEED * direction;
	for area in get_overlapping_areas():
		if area.get_parent() is BoarMob:
			var boarMob = area.get_parent() as BoarMob;
			boarMob.got_hit(DAMAGE, 1);
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free();
