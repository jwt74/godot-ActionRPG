extends Node2D

const GrassEffect = preload("res://Effects/HeartGrassEffect.tscn")
var stats = PlayerStats

func create_grass_effect():
	var grassEffect = GrassEffect.instance()
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position

func _on_Hurtbox_area_entered(area):
	create_grass_effect()
	stats.health += 1
	queue_free()
