extends KinematicBody2D

var knockback = Vector2.ZERO

func _physics_process(delta):
	move_and_slide(knockback)
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	
func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 120
#	queue_free()
