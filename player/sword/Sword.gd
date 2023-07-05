extends Node3D

signal enemy_hit

var col_active = false

func _on_area_3d_body_entered(body):
	if body is Enemy:
		emit_signal("enemy_hit", body)

func set_collision_active(v):
	$Area3D.monitorable = v
	$Area3D.monitoring = v
