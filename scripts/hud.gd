class_name Hud
extends CanvasLayer

@export var medal_icons: Dictionary[Medal.Tier, Texture2D] = {}

@onready var _score_label: Label = $ScoreLabel
@onready var _ready_panel: Control = $ReadyPanel
@onready var _game_over_panel: Control = $GameOverPanel
@onready var _final_score_label: Label = $GameOverPanel/FinalScoreLabel
@onready var _best_score_label: Label = $GameOverPanel/BestScoreLabel
@onready var _medal_icon: TextureRect = $GameOverPanel/MedalIcon


func show_ready() -> void:
	_score_label.hide()
	_game_over_panel.hide()
	_ready_panel.show()


func show_score(score: int) -> void:
	_ready_panel.hide()
	_score_label.text = str(score)
	_score_label.show()


func show_game_over(score: int, best: int) -> void:
	_score_label.hide()
	_final_score_label.text = "Score %d" % score
	_best_score_label.text = "Best %d" % best
	_show_medal(Medal.tier_for_score(score))
	_game_over_panel.show()


func _show_medal(tier: Medal.Tier) -> void:
	_medal_icon.texture = medal_icons.get(tier)
	_medal_icon.visible = _medal_icon.texture != null
