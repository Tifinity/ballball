extends Node2D

const ARENA_W: float = 900.0
const ARENA_H: float = 650.0
const WALL_T: float = 24.0
const WALL_VISUAL: float = 16.0
const NUM_BALLS: int = 6
const BALL_RADIUS: float = 20.0

var ball_scene: PackedScene = preload("res://scenes/Ball.tscn")
var alive_balls: Array = []
var game_over: bool = false

var ball_configs: Array = [
	{"color": Color(0.95, 0.25, 0.25), "speed": 220.0, "hp": 110.0},                                    # 红（无能力）
	{"color": Color(0.25, 0.55, 0.95), "speed": 200.0, "hp": 95.0,  "ability": "SwordShield"},          # 蓝（剑盾）
	{"color": Color(0.25, 0.85, 0.35), "speed": 160.0, "hp": 130.0, "ability": "Mine"},                 # 绿（地雷，慢血多）
	{"color": Color(0.95, 0.85, 0.15), "speed": 230.0, "hp": 85.0,  "ability": "Gun"},                  # 黄（枪）
	{"color": Color(0.75, 0.25, 0.95), "speed": 195.0, "hp": 100.0, "ability": "SwordShield"},          # 紫（剑盾）
	{"color": Color(0.95, 0.55, 0.10), "speed": 260.0, "hp": 75.0,  "ability": "Gun"},                  # 橙（枪，最快）
]

func _ready() -> void:
	_setup_arena()
	_spawn_balls()

func _setup_arena() -> void:
	# 内边缘与可视围墙对齐（WALL_VISUAL 处）
	_create_wall(Vector2(ARENA_W / 2.0, WALL_VISUAL - WALL_T / 2.0),
			Vector2(ARENA_W + WALL_T * 2.0, WALL_T))
	_create_wall(Vector2(ARENA_W / 2.0, ARENA_H - WALL_VISUAL + WALL_T / 2.0),
			Vector2(ARENA_W + WALL_T * 2.0, WALL_T))
	_create_wall(Vector2(WALL_VISUAL - WALL_T / 2.0, ARENA_H / 2.0),
			Vector2(WALL_T, ARENA_H + WALL_T * 2.0))
	_create_wall(Vector2(ARENA_W - WALL_VISUAL + WALL_T / 2.0, ARENA_H / 2.0),
			Vector2(WALL_T, ARENA_H + WALL_T * 2.0))

func _create_wall(pos: Vector2, size: Vector2) -> void:
	var wall := StaticBody2D.new()
	wall.position = pos
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	col.shape = shape
	wall.add_child(col)
	add_child(wall)

func _spawn_balls() -> void:
	var margin := BALL_RADIUS + 40.0
	for i in range(NUM_BALLS):
		var ball = ball_scene.instantiate()
		# 均匀分布在场地中，避免重叠
		var cols := 3
		var rows := 2
		var cell_w := (ARENA_W - margin * 2.0) / cols
		var cell_h := (ARENA_H - margin * 2.0) / rows
		var col_idx := i % cols
		@warning_ignore("integer_division")
		var row_idx: int = i / cols
		var pos := Vector2(
			margin + cell_w * col_idx + cell_w / 2.0 + randf_range(-30.0, 30.0),
			margin + cell_h * row_idx + cell_h / 2.0 + randf_range(-30.0, 30.0)
		)
		add_child(ball)
		ball.position = pos
		var cfg: Dictionary = ball_configs[i % ball_configs.size()]
		ball.setup(cfg["color"], i, cfg["speed"], cfg["hp"], self, cfg.get("ability", ""))
		alive_balls.append(ball)

func on_ball_died(ball: Node) -> void:
	alive_balls.erase(ball)
	ball.queue_free()

	if alive_balls.size() <= 1 and not game_over:
		game_over = true
		_show_winner()

func _show_winner() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.55)
	overlay.size = Vector2(ARENA_W, ARENA_H)
	overlay.position = Vector2.ZERO
	add_child(overlay)

	var label := Label.new()
	label.add_theme_font_size_override("font_size", 52)
	if alive_balls.size() == 1:
		var winner = alive_balls[0]
		label.text = "Ball %d  Wins!" % winner.ball_id
		label.add_theme_color_override("font_color", winner.ball_color)
	else:
		label.text = "Draw!"
		label.add_theme_color_override("font_color", Color.WHITE)
	label.position = Vector2(ARENA_W / 2.0 - 150.0, ARENA_H / 2.0 - 40.0)
	add_child(label)

	var hint := Label.new()
	hint.text = "Press R to restart"
	hint.add_theme_font_size_override("font_size", 22)
	hint.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	hint.position = Vector2(ARENA_W / 2.0 - 100.0, ARENA_H / 2.0 + 30.0)
	add_child(hint)

func _input(event: InputEvent) -> void:
	if game_over and event is InputEventKey:
		if event.pressed and event.keycode == KEY_R:
			get_tree().reload_current_scene()

func _draw() -> void:
	# 全屏背景
	draw_rect(Rect2(0, 0, ARENA_W, ARENA_H), Color(0.08, 0.08, 0.14))

	# 围墙填充
	var wall_fill := Color(0.22, 0.30, 0.46)
	draw_rect(Rect2(0, 0, ARENA_W, WALL_VISUAL), wall_fill)
	draw_rect(Rect2(0, ARENA_H - WALL_VISUAL, ARENA_W, WALL_VISUAL), wall_fill)
	draw_rect(Rect2(0, WALL_VISUAL, WALL_VISUAL, ARENA_H - WALL_VISUAL * 2.0), wall_fill)
	draw_rect(Rect2(ARENA_W - WALL_VISUAL, WALL_VISUAL, WALL_VISUAL, ARENA_H - WALL_VISUAL * 2.0), wall_fill)

	# 围墙内边缘高亮线
	var wall_edge := Color(0.45, 0.58, 0.82)
	var inner := WALL_VISUAL
	draw_line(Vector2(inner, inner), Vector2(ARENA_W - inner, inner), wall_edge, 2.0)
	draw_line(Vector2(inner, ARENA_H - inner), Vector2(ARENA_W - inner, ARENA_H - inner), wall_edge, 2.0)
	draw_line(Vector2(inner, inner), Vector2(inner, ARENA_H - inner), wall_edge, 2.0)
	draw_line(Vector2(ARENA_W - inner, inner), Vector2(ARENA_W - inner, ARENA_H - inner), wall_edge, 2.0)

	# 场地网格（仅围墙内）
	var grid_step := 80.0
	var grid_color := Color(1, 1, 1, 0.04)
	var x := inner + fmod(ARENA_W - inner * 2.0, grid_step) / 2.0 + grid_step
	while x < ARENA_W - inner:
		draw_line(Vector2(x, inner), Vector2(x, ARENA_H - inner), grid_color)
		x += grid_step
	var y := inner + fmod(ARENA_H - inner * 2.0, grid_step) / 2.0 + grid_step
	while y < ARENA_H - inner:
		draw_line(Vector2(inner, y), Vector2(ARENA_W - inner, y), grid_color)
		y += grid_step
