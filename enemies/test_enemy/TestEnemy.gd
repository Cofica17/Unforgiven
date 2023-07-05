extends CharacterBody3D
class_name Enemy

@onready var anim_player:AnimationPlayer = $enemy/AnimationPlayer
@onready var anim_tree:AnimationTree = $AnimationTree

var cur_hit_anim_idx = 1

func on_hit():
	anim_tree.set("parameters/Anims/transition_request", "hit_"+str(cur_hit_anim_idx))
	cur_hit_anim_idx += 1
	if cur_hit_anim_idx > 3:
		cur_hit_anim_idx = 1

func _on_animation_tree_animation_finished(anim_name):
	anim_tree.set("parameters/Anims/transition_request", "idle")
