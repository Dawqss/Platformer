extends CharacterBody2D

class_name BoarMobController

enum StateCase {
	Idle,
	Run,
	Damaged,
	Vanishing,
	Falling,
}

enum DirectionState {
	FacingLeft,
	FacingRight
}

const SPEED = 80.0
const DAMAGE = 10;
const MAX_HEALTH = 20;

var label: Label;
var label_start_positon: Vector2;
var label_shift_positon = Vector2(1, 1);
var label_opacity = 1;

var ray_cast: RayCast2D;
var ray_cast_start_positon: Vector2;

var damage_label_timer: Timer;
var health_bar: HealthBar;

var stunTimer: Timer;

var animated_sprite: AnimatedSprite2D;

var current_damage = null;
var should_show_damage_label = false;
var current_health = MAX_HEALTH;

@export var direction = -1;

var current_direction_state = DirectionState.FacingLeft;
var current_state: StateCase = StateCase.Run;
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func set_state(new_state: StateCase) -> void:
	current_state = new_state;
	
func set_direction_state(new_direction_state: DirectionState):
	current_direction_state = new_direction_state;

func init_label(new_label: Label, new_label_timer: Timer):
	label = new_label;
	label_start_positon = label.position;
	label.text = '';
	label.modulate = Color(1.0, 0.09, 0, 1);
	damage_label_timer = new_label_timer;
	
func init_ray_cast(new_ray_cast: RayCast2D):
	ray_cast = new_ray_cast;
	ray_cast_start_positon = ray_cast.position;
	
func init_health_bar(new_health_bar: HealthBar):
	health_bar = new_health_bar;
	health_bar.hide();
	health_bar.set_max_health(MAX_HEALTH);
	
func init_stun_timer(new_stun_timer: Timer):
	stunTimer = new_stun_timer;
	
func init_animated_sprite(new_animated_sprite: AnimatedSprite2D):
	animated_sprite = new_animated_sprite;
	animated_sprite.play("Idle");
	
func on_stun_timer_timeout():
	print('stun_end');
	
func reset_label():
	label.hide();
	label.position = label_start_positon;
	label.modulate = Color(1.0, 0.09, 0, 1);
	label_opacity = 1;
	
func set_should_show_damage_label(should: bool):
	should_show_damage_label = should;
	
func show_damage_label_with_delta(delta: float):
	if should_show_damage_label:
		label.text = str('-', current_damage);
		label.show();
		label.position.y += label.position.y * delta;
		label_opacity = label_opacity - delta;
		label.modulate = Color(1.0, 0.09, 0, label_opacity);

func prepare_state_for_boar(is_on_floor: bool) -> StateCase:
	if current_state == StateCase.Vanishing:
		return StateCase.Vanishing;
	if current_state == StateCase.Damaged:
		return StateCase.Damaged;
	if !is_on_floor:
		return StateCase.Falling;
	return StateCase.Run;

func set_boar_animation():
	match current_state:
		StateCase.Falling:
			animated_sprite.animation = "Idle";
		StateCase.Run:
			animated_sprite.animation = "Run";
		StateCase.Damaged:
			animated_sprite.animation = "Damage";	
		StateCase.Vanishing:
			animated_sprite.animation = "Vanish";
func set_animation_flip(direction_state: DirectionState):
	if direction_state == DirectionState.FacingLeft:
		animated_sprite.flip_h = false;
	else:
		animated_sprite.flip_h = true;
			
func set_boar_velocity(delta: float):
	if velocity.x > 0:
		direction = 1;
		set_direction_state(DirectionState.FacingRight)
	if velocity.x < 0:
		direction = -1;
		set_direction_state(DirectionState.FacingLeft);
	match current_state:
		StateCase.Run:
			if ray_cast.get_collider():
				velocity.x = direction * SPEED;
			else:
				velocity.x = -direction * SPEED;
		StateCase.Falling:
			velocity.y += gravity * delta;
		StateCase.Damaged:
			velocity.x = 0;

func set_current_health(damage: int):
	current_health = clamp(current_health - damage, 0, MAX_HEALTH);

func set_ray_cast_side(direction: int):
	ray_cast.position.x = -direction * ray_cast_start_positon.x;
