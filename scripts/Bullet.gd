extends Area2D

var speed: float = 380.0
var damage: float = 15.0
var lifetime: float = 2.5
var owner_ball: Node = null

const BULLET_RADIUS: float = 5.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
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
