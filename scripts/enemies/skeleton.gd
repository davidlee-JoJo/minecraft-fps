extends Enemy
class_name Skeleton

func _init() -> void:
	enemy_type = "skeleton"
	max_health = 35
	move_speed = 3.2
	attack_damage = 8
	attack_range = 12.0
	attack_cooldown = 1.8
	body_color = Color(0.85, 0.85, 0.8)
	accent_color = Color(0.3, 0.3, 0.32)
	score_value = 15
	is_ranged = true
	projectile_speed = 16.0
