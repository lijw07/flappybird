class_name PipePair
extends Node2D

signal passed

const DESPAWN_X := -40.0

@onready var _top_pipe: StaticBody2D = $TopPipe
@onready var _bottom_pipe: StaticBody2D = $BottomPipe
@onready var _score_zone: Area2D = $ScoreZone

var _is_scrolling := true


func _ready() -> void:
	var half_gap := GameConfig.PIPE_GAP / 2.0
	_top_pipe.position.y = -half_gap
	_bottom_pipe.position.y = half_gap


func _process(delta: float) -> void:
	if not _is_scrolling:
		return
	position.x -= GameConfig.SCROLL_SPEED * delta
	if position.x < DESPAWN_X:
		queue_free()


func stop() -> void:
	_is_scrolling = false


func _on_score_zone_body_entered(_body: Node2D) -> void:
	_score_zone.set_deferred("monitoring", false)
	passed.emit()
