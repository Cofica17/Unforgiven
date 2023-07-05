extends PlayerState

signal attack_anim_playing(v)

@onready var attack_timer:Timer = $AttackTimer

var cur_anim_idx = 1

func enter():
	play_next_anim()

func process(delta):
	# we'll handle state transitions ourselves
	pass
 
func physics_process(delta):
	set_horizontal_movement(0.1, 0.0, 0.0, 1.5, delta)
	
	if player.controls.is_primary_attack() and attack_timer.is_stopped():
		play_next_anim()

func _on_animation_tree_animation_finished(anim):
	emit_signal("attack_anim_playing", false)
	if player.controls.is_primary_attack() and "Sword_Attack_" in anim:
		play_next_anim()
	else:
		player.anim_tree.set("parameters/RootState/transition_request", "on-ground")
		state_machine.transition_to("OnGround")

func _on_attack_timer_timeout():
	if player.controls.is_primary_attack():
		play_next_anim()

func play_next_anim():
	print("primary_attack_"+str(cur_anim_idx))
	play_anim("primary_attack_"+str(cur_anim_idx))

func play_anim(anim:String):
	emit_signal("attack_anim_playing", true)
	match cur_anim_idx:
		1:
			attack_timer.start(0.77)
		2:
			attack_timer.start(0.95)
		3:
			attack_timer.start(1.3)
	
	player.anim_tree.set("parameters/AttackState/transition_request", anim)
	player.anim_tree.set("parameters/RootState/transition_request", "attack")
	cur_anim_idx += 1
	if cur_anim_idx > 3:
		cur_anim_idx = 1

func exit():
	cur_anim_idx = 1

func _on_running_attack_running_attack_anim_playing(v):
	if v:
		cur_anim_idx = 1
