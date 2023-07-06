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
var step_distance = 1.7
var stop_acceleration = 2.7
var trigger_step_time = 0.05
var step_triggered = false

func _ready():
	super()
	connect("attack_anim_playing", player.set_sword_collision_enabled)

func enter():
	timer = 0.0
	emit_attack_anim_playing_once = 0
	if not player.anim_tree.animation_finished.is_connected(_on_animation_tree_animation_finished):
		player.anim_tree.animation_finished.connect(_on_animation_tree_animation_finished)
	
	play_anim()
	step_triggered = false

func process(delta):
	# we'll handle state transitions ourselves
	pass

func physics_process(delta):
	timer += delta
	
	if not step_triggered and timer >= trigger_step_time:
		player.horizontal_velocity = player.get_current_look_at_dir() * step_distance
		step_triggered = true
	elif step_triggered:
		player.horizontal_velocity = player.horizontal_velocity.lerp(Vector3.ZERO, stop_acceleration * delta)
	
	if player.controls.is_primary_attack() and timer >= next_attack_cutoff:
		state_machine.transition_to("OnGround/Attacks/"+next_state)
	
	if timer >= attack_window_from and timer <= attack_window_to and emit_attack_anim_playing_once == 0:
		emit_signal("attack_anim_playing", true)
		emit_attack_anim_playing_once += 1
	elif emit_attack_anim_playing_once == 1:
		emit_signal("attack_anim_playing", false)
		emit_attack_anim_playing_once += 1

func _on_animation_tree_animation_finished(anim):
	player.anim_tree.set("parameters/RootState/transition_request", "on-ground")
	state_machine.transition_to("OnGround")

func play_anim():
	player.anim_tree.set("parameters/AttackState/transition_request", anim)
	player.anim_tree.set("parameters/RootState/transition_request", "attack")

func set_snap_movement(speed, turn_speed, cam_follow_speed, acceleration, delta):
	var move_dir = player.controls.get_movement_vector()
	var direction = -player.skin.global_transform.basis.z
	
	player.move_rot = lerpf(player.move_rot, deg_to_rad(player.camera._rot_h), cam_follow_speed * delta)
	#direction = direction.rotated(Vector3.UP, player.move_rot)
	
	player.horizontal_velocity = lerp(player.horizontal_velocity, direction * speed, acceleration * delta)
	
	if move_dir != Vector2.ZERO:
		player.skin.rotation.y = lerp_angle(player.skin.rotation.y, atan2(-direction.x, -direction.z), turn_speed * delta)
