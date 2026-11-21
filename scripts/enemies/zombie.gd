extends Enemy
class_name Zombie

func _init() -> void:
	enemy_type = "zombie"
	max_health = 50
	move_speed = 2.4
	attack_damage = 10
	attack_range = 1.8
	attack_cooldown = 1.1
	body_color = Color(0.2, 0.55, 0.25)
	accent_color = Color(0.25, 0.35, 0.6)
	score_value = 10
	is_ranged = false
