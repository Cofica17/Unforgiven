extends PlayerState

signal attack_anim_playing(v)

@export var anim:String
@export var next_state:String
@export var attack_window:float = 0.0

var attack_timer:Timer

func _ready():
	super()
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	add_child(attack_timer)

func enter():
	play_anim()
	attack_timer.start(attack_window)

func process(delta):
	# we'll handle state transitions ourselves
	pass
 
func physics_process(delta):
	set_horizontal_movement(0.1, 0.0, 0.0, 1.5, delta)
	
	if player.controls.is_primary_attack() and attack_timer.is_stopped():
		state_machine.transition_to("OnGround/Attacks/"+next_state)

func _on_animation_tree_animation_finished(anim):
	emit_signal("attack_anim_playing", false)
	
	player.anim_tree.set("parameters/RootState/transition_request", "on-ground")
	state_machine.transition_to("OnGround")

func play_anim():
	emit_signal("attack_anim_playing", true)
	player.anim_tree.set("parameters/AttackState/transition_request", anim)
	player.anim_tree.set("parameters/RootState/transition_request", "attack")
