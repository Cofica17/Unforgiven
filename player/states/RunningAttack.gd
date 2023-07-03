extends PlayerState

func enter():
	player.anim_tree.set("parameters/AttackState/transition_request", "running_attack")
	player.anim_tree.set("parameters/RootState/transition_request", "attack")

func process(delta):
	# we'll handle state transitions ourselves
	pass

func physics_process(delta):
	set_horizontal_movement(0.0, 0.0, 0.0, 0.6, delta)

func _on_animation_tree_animation_finished(anim):
	if anim == "Running_Sword_Attack":
		state_machine.transition_to("OnGround")
