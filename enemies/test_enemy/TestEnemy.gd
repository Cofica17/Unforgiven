extends Node3D

@onready var anim_player:AnimationPlayer = $enemy/AnimationPlayer

func on_hit():
	anim_player.play("Hit_1")

func _on_animation_player_animation_finished(anim_name):
	anim_player.play("Idle")
