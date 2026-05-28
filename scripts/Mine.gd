extends Area2D

var damage: float = 45.0
var lifetime: float = 8.0
var owner_ball: Node = null
var armed: bool = false
var arm_delay: float = 0.8
var flash_timer: float = 0.0

func _ready() -> void:
	monitoring = false
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 14.0
	col.shape = shape
	add_child(col)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	arm_delay -= delta
	if arm_delay <= 0.0 and not armed:
		armed = true
		monitoring = true

	lifetime -= delta
	flash_timer += delta
	if lifetime <= 0.0:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var base_color: Color
	if not armed:
		base_color = Color(0.45, 0.45, 0.45)
	elif lifetime < 2.0:
		base_color = Color(1.0, 0.15, 0.15) if int(flash_timer * 5.0) % 2 == 0 else Color(0.7, 0.05, 0.05)
	else:
		base_color = Color(0.15, 0.65, 0.20)

	# 地雷主体
	draw_circle(Vector2.ZERO, 10.0, base_color)
	draw_arc(Vector2.ZERO, 10.0, 0.0, TAU, 32, Color(0.0, 0.0, 0.0, 0.4), 2.0)

	# 刺
	var spikes := 8
	for i in spikes:
		var angle := TAU * i / spikes
		var inner := Vector2.RIGHT.rotated(angle) * 10.0
		var outer := Vector2.RIGHT.rotated(angle) * 17.0
		draw_line(inner, outer, base_color.darkened(0.25), 2.0)

func _on_body_entered(body: Node) -> void:
	if not armed:
		return
	if is_instance_valid(owner_ball) and body == owner_ball:
		return
	if body is StaticBody2D:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
