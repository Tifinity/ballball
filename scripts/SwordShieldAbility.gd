extends Node2D

const ROTATION_SPEED: float = 2.8
const BALL_RADIUS: float = 20.0
const SWORD_LENGTH: float = 30.0
const SWORD_DAMAGE: float = 25.0
const HIT_COOLDOWN: float = 0.4

var hit_cooldown: float = 0.0

func _ready() -> void:
	$SwordArea.body_entered.connect(_on_sword_hit)

func _physics_process(delta: float) -> void:
	rotation += ROTATION_SPEED * delta
	hit_cooldown = maxf(0.0, hit_cooldown - delta)
	queue_redraw()

func _draw() -> void:
	var ball := get_parent()
	if not is_instance_valid(ball):
		return

	var bc: Color = ball.ball_color

	# 盾牌（本地 Y 正方向 = 旋转的"下"侧）
	var shield_y := BALL_RADIUS + 8.0
	draw_arc(Vector2(0.0, shield_y), 14.0, deg_to_rad(25.0), deg_to_rad(155.0), 16, bc.lightened(0.35), 6.0)

	# 剑柄
	draw_rect(Rect2(-3.0, -(BALL_RADIUS + 10.0), 6.0, 10.0), Color(0.50, 0.32, 0.12))
	# 护手
	draw_rect(Rect2(-9.0, -(BALL_RADIUS + 10.0), 18.0, 4.0), Color(0.72, 0.60, 0.18))
	# 剑身
	draw_rect(Rect2(-2.5, -(BALL_RADIUS + SWORD_LENGTH), 5.0, SWORD_LENGTH - 10.0), Color(0.82, 0.86, 0.92))
	# 剑尖
	var tip := Vector2(0.0, -(BALL_RADIUS + SWORD_LENGTH + 8.0))
	draw_line(Vector2(-2.5, -(BALL_RADIUS + SWORD_LENGTH)), tip, Color(0.92, 0.94, 1.0), 2.0)
	draw_line(Vector2(2.5, -(BALL_RADIUS + SWORD_LENGTH)), tip, Color(0.92, 0.94, 1.0), 2.0)

func _on_sword_hit(body: Node) -> void:
	if hit_cooldown > 0.0:
		return
	var ball := get_parent()
	if body == ball or not body.has_method("take_damage"):
		return
	body.take_damage(SWORD_DAMAGE)
	hit_cooldown = HIT_COOLDOWN
