class_name PipeSpawner
extends Node2D

signal pipe_passed

const PIPE_HALF_WIDTH := 16.0

@export var pipe_pair_scene: PackedScene

@onready var _spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	_spawn_timer.wait_time = GameConfig.PIPE_SPAWN_INTERVAL


func start() -> void:
	_spawn_timer.start()


func stop() -> void:
	_spawn_timer.stop()
	for pipe_pair in _active_pipe_pairs():
		pipe_pair.stop()


func _on_spawn_timer_timeout() -> void:
	var pipe_pair := pipe_pair_scene.instantiate() as PipePair
	pipe_pair.position = Vector2(_spawn_x(), _random_gap_center_y())
	pipe_pair.passed.connect(pipe_passed.emit)
	add_child(pipe_pair)


func _spawn_x() -> float:
	return get_viewport_rect().size.x + PIPE_HALF_WIDTH


func _random_gap_center_y() -> float:
	var half_gap := GameConfig.PIPE_GAP / 2.0
	var lowest := GameConfig.PIPE_VERTICAL_MARGIN + half_gap
	var highest := GameConfig.GROUND_TOP_Y - GameConfig.PIPE_VERTICAL_MARGIN - half_gap
	return randf_range(lowest, highest)


func _active_pipe_pairs() -> Array[PipePair]:
	var pipe_pairs: Array[PipePair] = []
	for child in get_children():
		if child is PipePair:
			pipe_pairs.append(child)
	return pipe_pairs
