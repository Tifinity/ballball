extends Node2D

const DROP_MIN: float = 2.5
const DROP_MAX: float = 4.0

var drop_timer: float = 2.0
var drop_interval: float = 3.0

const _MINE_SCRIPT = preload("res://scripts/Mine.gd")

func _ready() -> void:
	drop_interval = randf_range(DROP_MIN, DROP_MAX)
	drop_timer = drop_interval

func _physics_process(delta: float) -> void:
	drop_timer -= delta
	if drop_timer <= 0.0:
		_drop_mine()
		drop_interval = randf_range(DROP_MIN, DROP_MAX)
		drop_timer = drop_interval
	queue_redraw()

func _drop_mine() -> void:
	var ball := get_parent()
	if not is_instance_valid(ball) or ball.game_manager == null:
		return

	var mine = _MINE_SCRIPT.new()
	mine.position = ball.global_position
	mine.owner_ball = ball
	ball.game_manager.add_child(mine)

func _draw() -> void:
	# 充能弧形：随时间填满，表示距离下次投雷的时间
	var progress := 1.0 - drop_timer / drop_interval
	var arc_color := Color(0.20, 0.85, 0.30, 0.75)
	draw_arc(Vector2.ZERO, 26.0, -PI / 2.0, -PI / 2.0 + TAU * progress, 24, arc_color, 3.0)
