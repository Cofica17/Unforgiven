extends PlayerState

func enter():
	player.anim_tree.set("parameters/RootState/transition_request", "state 5")

func process(delta):
	# we'll handle state transitions ourselves
	pass

func physics_process(delta):
	pass

func _on_animation_tree_animation_finished(anim):
	if anim == "Sword_Attack_1":
		state_machine.transition_to("OnGround")
