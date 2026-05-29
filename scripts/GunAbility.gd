extends Node2D

const BULLET_SPEED: float = 380.0
const BULLET_DAMAGE: float = 15.0
const FIRE_MIN: float = 1.2
const FIRE_MAX: float = 2.5
const BALL_RADIUS: float = 20.0

var fire_timer: float = 1.0
var fire_interval: float = 1.8
var barrel_angle: float = 0.0

const _BULLET_SCENE = preload("res://scenes/Bullet.tscn")

func _ready() -> void:
	fire_interval = randf_range(FIRE_MIN, FIRE_MAX)
	fire_timer = fire_interval

func _physics_process(delta: float) -> void:
	fire_timer -= delta
	if fire_timer <= 0.0:
		_fire()
		fire_interval = randf_range(FIRE_MIN, FIRE_MAX)
		fire_timer = fire_interval
	queue_redraw()

func _fire() -> void:
	var ball := get_parent()
	if not is_instance_valid(ball) or ball.game_manager == null:
		return

	barrel_angle = randf() * TAU
	var dir := Vector2.RIGHT.rotated(barrel_angle)

	var bullet := _BULLET_SCENE.instantiate()
	bullet.position = ball.global_position + dir * (BALL_RADIUS + 6.0)
	bullet.rotation = barrel_angle
	bullet.speed = BULLET_SPEED
	bullet.damage = BULLET_DAMAGE
	bullet.owner_ball = ball
	ball.game_manager.add_child(bullet)

func _draw() -> void:
	var ball := get_parent()
	if not is_instance_valid(ball):
		return

	var dir := Vector2.RIGHT.rotated(barrel_angle)
	var barrel_start := dir * BALL_RADIUS
	var barrel_end := dir * (BALL_RADIUS + 20.0)

	# 枪身
	var perp := dir.rotated(PI / 2.0)
	var body_center := dir * (BALL_RADIUS - 4.0)
	draw_line(body_center - perp * 5.0, body_center + perp * 5.0, Color(0.30, 0.32, 0.36), 8.0)
	# 枪管
	draw_line(barrel_start, barrel_end, Color(0.45, 0.48, 0.52), 5.0)
	draw_circle(barrel_end, 3.5, Color(0.55, 0.58, 0.62))
