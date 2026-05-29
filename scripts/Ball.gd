class_name Ball
extends RigidBody2D

var max_hp: float = 100.0
var current_hp: float = 100.0
var move_speed: float = 200.0
var collision_damage: float = 10.0
var ball_color: Color = Color.RED
var ball_id: int = 0
var game_manager: Node = null

var damage_cooldown: float = 0.0

const DAMAGE_COOLDOWN_TIME: float = 0.5
const BALL_RADIUS: float = 20.0

const ABILITY_SCENES := {
	"SwordShield": preload("res://scenes/SwordShieldAbility.tscn"),
	"Gun":         preload("res://scenes/GunAbility.tscn"),
	"Mine":        preload("res://scenes/MineAbility.tscn"),
}

func _ready() -> void:
	gravity_scale = 0.0
	linear_damp = 0.0
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 1.0
	physics_material_override.friction = 0.0

func _physics_process(delta: float) -> void:
	damage_cooldown = maxf(0.0, damage_cooldown - delta)

	# 保持匀速直线运动
	if linear_velocity.length() > 0.5:
		linear_velocity = linear_velocity.normalized() * move_speed

	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, BALL_RADIUS, ball_color)
	draw_arc(Vector2.ZERO, BALL_RADIUS, 0, TAU, 32, Color(1, 1, 1, 0.4), 2.0)

	var bar_w := BALL_RADIUS * 2.0
	var bar_h := 5.0
	var bar_y := -BALL_RADIUS - 12.0
	draw_rect(Rect2(-bar_w / 2.0, bar_y, bar_w, bar_h), Color(0.15, 0.15, 0.15))

	var hp_ratio := current_hp / max_hp
	var fill_color := Color(1.0 - hp_ratio, hp_ratio, 0.0)
	draw_rect(Rect2(-bar_w / 2.0, bar_y, bar_w * hp_ratio, bar_h), fill_color)

	draw_string(ThemeDB.fallback_font, Vector2(-5, 6), str(ball_id), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

	# Cascade draw to ability children
	for child in get_children():
		if child.has_method("queue_redraw"):
			child.queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D:
		var rb := body as RigidBody2D
		var push_dir := global_position - rb.global_position
		if push_dir.length_squared() < 0.001:
			push_dir = Vector2.RIGHT.rotated(randf() * TAU)
		apply_central_impulse(push_dir.normalized() * move_speed * mass * 0.5)

	if damage_cooldown > 0.0:
		return
	if body.has_method("take_damage"):
		body.take_damage(collision_damage)
		damage_cooldown = DAMAGE_COOLDOWN_TIME

func take_damage(amount: float) -> void:
	current_hp -= amount
	if current_hp <= 0.0 and game_manager != null:
		game_manager.on_ball_died(self)

func setup(color: Color, id: int, speed: float, hp: float, manager: Node, ability_type: String = "") -> void:
	ball_color = color
	ball_id = id
	move_speed = speed
	max_hp = hp
	current_hp = hp
	game_manager = manager
	linear_velocity = Vector2.RIGHT.rotated(randf() * TAU) * speed

	if ability_type in ABILITY_SCENES:
		var ability_scene: PackedScene = ABILITY_SCENES[ability_type]
		add_child(ability_scene.instantiate())
