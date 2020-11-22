extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export(int) var ACCELERATION = 200
export(int) var MAX_SPEED = 50
export(int) var FRICTION = 200
export(int) var WANDER_TARGET_MARGIN = 4
export(int) var KNOCKBACK = 160
export(bool) var WANDERER = true
export(float) var INVINCIBLE_DURATION = 0.3

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = pick_random_state([IDLE, WANDER])

onready var stats = $Stats
onready var playerDectectionZone = $PlayerDectectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	randomize()

func createEnemyDeathEffect():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	
func _physics_process(delta):
	move_and_slide(knockback)
	knockback = knockback.move_toward(Vector2.ZERO, rand_range(150,250) * delta)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			if wanderController.get_time_left() == 0:
				reset_state()
			seek_player()

		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				reset_state()
			accelerate_toward_point(wanderController.target_position, delta)
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_MARGIN:
				reset_state()

		CHASE:
			var player = playerDectectionZone.player
			if player != null:
				accelerate_toward_point(player.global_position, delta)
			else:
				state = IDLE
				
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)	
				
func reset_state():
	if WANDERER:
		state = pick_random_state([IDLE, WANDER])
		wanderController.start_wander_timer(rand_range(1, 3))
	else:
		state = IDLE
				
func accelerate_toward_point(target, delta):
	var direction = global_position.direction_to(target)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0	
	
func seek_player():
	if playerDectectionZone.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	if WANDERER:
		state_list.shuffle()
		return state_list.pop_front()
	else:
		return IDLE
			
func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * KNOCKBACK
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(INVINCIBLE_DURATION)
		
func _on_Stats_no_health():
	queue_free()
	createEnemyDeathEffect()

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
