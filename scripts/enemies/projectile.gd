extends Area3D
class_name Projectile
## Simple blocky projectile that flies straight and damages the player on contact.

var speed: float = 18.0
var damage: int = 10
var color: Color = Color(0.8, 0.2, 0.2)
var _dir: Vector3 = Vector3.FORWARD
var _life: float = 4.0
var _mesh: MeshInstance3D


func _ready() -> void:
	collision_layer = 8
	collision_mask = 1 | 2
	monitoring = true
	body_entered.connect(_on_body_entered)

	_mesh = MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.3, 0.3, 0.3)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.5
	mesh.material = mat
	_mesh.mesh = mesh
	add_child(_mesh)

	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.2
	col.shape = shape
	add_child(col)


func setup(dir: Vector3) -> void:
	_dir = dir.normalized()


func _physics_process(delta: float) -> void:
	global_position += _dir * speed * delta
	_life -= delta
	_mesh.rotate_x(delta * 8.0)
	if _life <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
