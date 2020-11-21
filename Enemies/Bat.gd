extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export(int) var ACCELERATION = 200
export(int) var MAX_SPEED = 50
export(int) var FRICTION = 200

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = CHASE

onready var stats = $Stats
onready var playerDectectionZone = $PlayerDectectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision

func createEnemyDeathEffect():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	
func _physics_process(delta):
	move_and_slide(knockback)
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			seek_player()
		WANDER:
			pass
		CHASE:
			var player = playerDectectionZone.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				sprite.flip_h = velocity.x < 0
			else:
				state = IDLE
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)	
		
func seek_player():
	if playerDectectionZone.can_see_player():
		state = CHASE
	
func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()
	
func _on_Stats_no_health():
	queue_free()
	createEnemyDeathEffect()
