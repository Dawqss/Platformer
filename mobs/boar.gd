extends BoarMobController

class_name BoarMob

func _ready():
	init_ray_cast($RayCast2D);
	init_label($DamageLabel, $DamageLabelTimer);
	init_health_bar($HealthBar);
	init_animated_sprite($AnimatedSprite2D);
	init_stun_timer($StunTimer);
		
func _physics_process(delta):
	#SET STATE BASED ON INPUT AND ENVIROMENT
	#CHECK STATE AND ACCORD TO PATH
	set_state(prepare_state_for_boar(is_on_floor()));
	set_boar_animation();
	set_boar_velocity(delta);
	set_ray_cast_side(direction);
	set_animation_flip(current_direction_state);
	
	show_damage_label_with_delta(delta);
	move_and_slide()

func _on_hit_box_area_entered(area):
	if area.get_parent() is Player:
		area.get_parent()._got_hit(DAMAGE);

func got_hit(damage: int, direction: float):
	current_damage = damage;
	set_should_show_damage_label(true);
	health_bar.show();
	set_current_health(damage);
	health_bar.set_label_value(str(current_health));
	
	if current_state == StateCase.Damaged:
		reset_label();
		stunTimer.stop();
		stunTimer.start();
		damage_label_timer.stop();
		damage_label_timer.start();
	else:	
		current_damage = damage;
		set_state(StateCase.Damaged);
		damage_label_timer.start();
		stunTimer.start();
	
func die():
	stunTimer.stop();
	damage_label_timer.stop();
	queue_free();

func _on_animated_sprite_2d_animation_looped():
	animated_sprite.animation;
	if current_health == 0 && animated_sprite.animation == "Damage":
		set_state(StateCase.Vanishing);
		
func _on_animated_sprite_2d_animation_finished():
	print('vanish');
	die();

func _on_stun_timer_timeout():
	stunTimer.stop();
	if current_health == 0:
		set_state(StateCase.Vanishing);
	else:
		set_state(StateCase.Run);

func _on_damage_label_timer_timeout():
	current_damage = null; #props only for label now
	damage_label_timer.stop();
	set_should_show_damage_label(false);
	reset_label();
