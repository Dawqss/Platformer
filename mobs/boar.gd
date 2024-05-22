extends CharacterBody2D

class_name BoarMob

@export var direction = 1;

const speed = 80.0
const DAMAGE = 10;
const MAX_HEALTH = 40;

var label: Label;
var damage_label_timer: Timer;
var health_bar: HealthBar;
var ray_cast: RayCast2D;
var ray_cast_start_positon: Vector2;

var label_start_positon: Vector2;
var label_shift_positon = Vector2(1, 1);
var label_opacity = 1;

var current_damage = null;

var is_damaged = false;
var current_health = MAX_HEALTH;
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$AnimatedSprite2D.play("Idle");
	ray_cast = $RayCast2D;
	ray_cast_start_positon = ray_cast.position;
	
	label = $DamageLabel;
	label_start_positon = label.position;
	damage_label_timer = $DamageLabelTimer;
	label.text = '';
	label.modulate = Color(1.0, 0.09, 0, 1);
	
	health_bar = $HealthBar;
	health_bar.hide();
	health_bar.set_max_health(MAX_HEALTH);

func _process(delta):
	if is_damaged:
		label.text = str('-', current_damage);
		label.show();
		label.position.y += label.position.y * delta;
		label_opacity = label_opacity - delta;
		label.modulate = Color(1.0, 0.09, 0, label_opacity);
	if abs(velocity.x) > 0:
		$AnimatedSprite2D.animation = 'Run';
		
func _physics_process(delta):
	#true -> right
	var current_direction = velocity.x > 0;
	if !ray_cast.is_colliding() && is_on_floor():
		if current_direction:
			direction = -1;
		else:
			direction = 1;
	ray_cast.position.x = ray_cast_start_positon.x * -direction;
	$AnimatedSprite2D.flip_h = bool(direction + 1);
	if !is_on_floor():
		velocity.y += gravity * delta;
	else:
		velocity.x = direction * speed;
	move_and_slide()

func _on_hit_box_area_entered(area):
	if area.get_parent() is Player:
		area.get_parent()._got_hit(DAMAGE);

func got_hit(damage: int):
	reset_label();
	health_bar.show();
	is_damaged = true;
	current_damage = damage;
	current_health = clamp(current_health - damage, 0, MAX_HEALTH);
	damage_label_timer.start();
	health_bar.set_label_value(str(current_health));
	$AnimatedSprite2D.play('Damage');

func _on_damage_label_timer_timeout():
	is_damaged = false;
	current_damage = null;
	reset_label();
	damage_label_timer.stop();
	$AnimatedSprite2D.play("Idle");
	
func reset_label():
	label.hide();
	label.position = label_start_positon;
	label.modulate = Color(1.0, 0.09, 0, 1);
	label_opacity = 1;

func die():
	queue_free();

func _on_animated_sprite_2d_animation_looped():
	if current_health == 0:
		die();
