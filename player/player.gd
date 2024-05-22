extends CharacterBody2D

class_name Player

const SPEED = 200.0;
const JUMP_VELOCITY = -300.0;
const DEFAULT_MAX_JUMPS = 2;
const DAMAGE = 5;

var is_wall_hugging = false;
var is_wall_jump = false;
var is_attacking = false;
var is_hitting_by_enemy = false;
var jump_count = 0;
var current_enemy_damage = null;
var enemy_in_melee_attack_range = false;
var attack_shape_start_position: Vector2;
var attack_shape_rotation: float;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal GotHit;

enum State {
	ATTACK,
	IDLE,
	JUMP,
	FALL,
	RUN,
	DAMAGED,
	DEAD
}

var CURRENT_STATE = State.IDLE;

func _ready():
	$Attack.monitorable = false;
	$AnimatedSprite2D.play('idle');
	attack_shape_start_position = $Attack/CollisionShape2D.position;
	attack_shape_rotation = $Attack/CollisionShape2D.rotation;

var direction;
var lastFacingDirection;

func _physics_process(delta):
	set_state();
	set_movement_effect(delta);
	if velocity.x == 0:
		set_animation(get_animation(), null);
	else:
		set_animation(get_animation(), velocity.x < 0);
	move_and_slide();
				
	#$Label.text = String("X: {x}, Y: {y}").format({"x": velocity.x, "y": velocity.y});
	#$Label.show();
func attack():
	for area in $Attack.get_overlapping_areas():
		if area.get_parent() is BoarMob:
			area.get_parent().got_hit(DAMAGE, lastFacingDirection);
	
func get_is_attack() -> bool:
	if Input.is_action_just_pressed('attack') && !is_attacking:
		$SlashSound.play();
		attack()
	if Input.is_action_just_pressed("attack") || is_attacking:
		return true;
	else:
		return false;
	
func jump():
	velocity.y = JUMP_VELOCITY;
	
func jump_observer_with_max_count(max_count):
	if is_on_floor() && jump_count != 0:
		jump_count = 0;
		is_wall_jump = false;
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump_count += 1;
			jump();
		elif jump_count < max_count:
			jump_count += 1;
			jump();		

func set_movement_effect(delta):
	direction = Input.get_axis("move_left", "move_right");
	if direction != 0:
		lastFacingDirection = direction;
	
	if !is_on_floor():
		velocity.y += gravity * delta;
		
	#wall_jump_observer(get_wall_normal(), direction);
	jump_observer_with_max_count(DEFAULT_MAX_JUMPS);
	is_attacking = get_is_attack();
	
	if direction && !is_attacking:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED / 10)

func set_animation(animation, isFlipHorizontal):
	$AnimatedSprite2D.animation = animation;
	if isFlipHorizontal != null:
		var multiVector;
		$AnimatedSprite2D.flip_h = isFlipHorizontal;
		if isFlipHorizontal:
			multiVector = Vector2(-1, 0);
		else:
			multiVector = Vector2(1, 0);
		$Attack/CollisionShape2D.position = attack_shape_start_position * multiVector;
		$Attack/CollisionShape2D.rotation = attack_shape_rotation * multiVector.x;
		
	match animation:
		'fall', 'jump', 'attack':
			pass;
		_:
			if !$AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.play();

func set_state():
	var absVelocity = abs(velocity.x);
	if is_hitting_by_enemy && !is_attacking:
		CURRENT_STATE = State.DAMAGED;
		return;
	if is_attacking:
		CURRENT_STATE = State.ATTACK;
		return;
	if velocity.y < 0:
		CURRENT_STATE = State.JUMP;
		return;
	if velocity.y > 0:
		CURRENT_STATE = State.FALL;
		return;
	if absVelocity == 0:
		CURRENT_STATE = State.IDLE
		return;
	if absVelocity > 0:
		CURRENT_STATE = State.RUN;
		
func get_animation():
	var absVelocity = abs(velocity.x)
	match CURRENT_STATE:
		State.ATTACK:
			return 'attack';
		State.JUMP:
			return 'jump';
		State.FALL:
			return 'fall';
		State.IDLE:
			return 'idle';
		State.RUN:
			return 'run';
		State.DAMAGED:
			return 'damaged';

func _on_animated_sprite_2d_animation_finished():
	if($AnimatedSprite2D.animation == 'attack'):
		is_attacking = false;

func _got_hit(number: int):
	$HitTimer.start();
	is_hitting_by_enemy = true;
	current_enemy_damage = number;
	emit_remove_health(number);
	
func _on_hitbox_area_exited(area):
	if area.get_parent() is BoarMob:
		is_hitting_by_enemy = false;
		current_enemy_damage = null;
		$HitTimer.stop();

func _on_hit_timer_timeout():
	if is_hitting_by_enemy && current_enemy_damage != null:
		emit_remove_health(current_enemy_damage);
	
func emit_remove_health(number: int):
	GotHit.emit(SignalsNames.names.REMOVE_HEALTH, number);

func _on_attack_area_entered(area: Area2D):
	enemy_in_melee_attack_range = true;

func _on_attack_area_exited(area):
	enemy_in_melee_attack_range = false;
