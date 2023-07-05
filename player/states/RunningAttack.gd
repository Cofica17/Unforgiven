extends PlayerState

signal running_attack_anim_playing

@onready var attack_timer = $AttackTimer

var attack_window = 0.9

func enter():
	emit_signal("running_attack_anim_playing", true)
	player.anim_tree.set("parameters/AttackState/transition_request", "running_attack")
	player.anim_tree.set("parameters/RootState/transition_request", "attack")
	attack_timer.start(attack_window)

func process(delta):
	# we'll handle state transitions ourselves
	pass

func physics_process(delta):
	set_horizontal_movement(0.0, 0.0, 0.0, 0.6, delta)

func _on_animation_tree_animation_finished(anim):
	if anim == "Running_Sword_Attack":
		play_next_anim()

func _on_attack_timer_timeout():
	if player.controls.is_primary_attack():
		play_next_anim()

func play_next_anim():
	emit_signal("running_attack_anim_playing", false)
	state_machine.transition_to("OnGround/Attacks/PrimaryAttack1")
