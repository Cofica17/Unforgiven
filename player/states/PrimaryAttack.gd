extends PlayerState

signal attack_anim_playing(v)

@export var anim:String
@export var next_state:String
@export var next_attack_cutoff:float = 0.0
@export var attack_window_from:float = 0.0
@export var attack_window_to:float = 0.0

var timer:float = 0.0
#Used to not have this signal emitted each frame needlesly
var emit_attack_anim_playing_once = 0

func _ready():
	super()
	connect("attack_anim_playing", player.set_sword_collision_enabled)

func enter():
	timer = 0.0
	emit_attack_anim_playing_once = 0
	if not player.anim_tree.animation_finished.is_connected(_on_animation_tree_animation_finished):
		player.anim_tree.animation_finished.connect(_on_animation_tree_animation_finished)
	
	play_anim()

func process(delta):
	# we'll handle state transitions ourselves
	pass
 
func physics_process(delta):
	timer += delta
	set_horizontal_movement(0.1, 0.0, 0.0, 1.5, delta)
	
	if player.controls.is_primary_attack() and timer >= next_attack_cutoff:
		state_machine.transition_to("OnGround/Attacks/"+next_state)
	
	if timer >= attack_window_from and timer <= attack_window_to:# and emit_attack_anim_playing_once == 0:
		emit_signal("attack_anim_playing", true)
		emit_attack_anim_playing_once += 1
	else:#elif emit_attack_anim_playing_once == 1:
		emit_signal("attack_anim_playing", false)
		emit_attack_anim_playing_once += 1

func _on_animation_tree_animation_finished(anim):
	player.anim_tree.set("parameters/RootState/transition_request", "on-ground")
	state_machine.transition_to("OnGround")

func play_anim():
	player.anim_tree.set("parameters/AttackState/transition_request", anim)
	player.anim_tree.set("parameters/RootState/transition_request", "attack")
