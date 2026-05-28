extends Area2D

var velocity: Vector2 = Vector2.ZERO
var damage: float = 15.0
var lifetime: float = 2.5
var owner_ball: Node = null

func _ready() -> void:
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 5.0
	col.shape = shape
	add_child(col)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.90, 0.20))
	draw_circle(Vector2.ZERO, 2.5, Color(1.0, 1.0, 0.70))

func _on_body_entered(body: Node) -> void:
	if is_instance_valid(owner_ball) and body == owner_ball:
		return
	if body is StaticBody2D:
		queue_free()
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
