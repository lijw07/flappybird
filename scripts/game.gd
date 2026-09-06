extends Node2D

enum State { READY, PLAYING, GAME_OVER }

@onready var _bird: Bird = $Bird
@onready var _pipe_spawner: PipeSpawner = $PipeSpawner
@onready var _backdrop: ScrollingBackdrop = $ScrollingBackdrop
@onready var _hud: Hud = $Hud
@onready var _sound_effects: SoundEffects = $SoundEffects
@onready var _restart_delay: Timer = $RestartDelay

var _state := State.READY
var _score := 0


func _ready() -> void:
	_hud.show_ready()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("flap"):
		return
	match _state:
		State.READY:
			_start_game()
		State.PLAYING:
			_flap()
		State.GAME_OVER:
			_restart_if_allowed()


func _start_game() -> void:
	_state = State.PLAYING
	_bird.start_flying()
	_pipe_spawner.start()
	_hud.show_score(_score)
	_flap()


func _flap() -> void:
	_bird.flap()
	_sound_effects.play_flap()


func _restart_if_allowed() -> void:
	if _restart_delay.is_stopped():
		get_tree().reload_current_scene()


func _on_pipe_spawner_pipe_passed() -> void:
	if _state != State.PLAYING:
		return
	_score += 1
	_hud.show_score(_score)
	_sound_effects.play_point()


func _on_bird_hit_obstacle() -> void:
	_state = State.GAME_OVER
	_pipe_spawner.stop()
	_backdrop.stop()
	_sound_effects.play_hit()
	_hud.show_game_over(_score, HighScoreStore.record(_score))
	_restart_delay.start()


func _on_bird_landed() -> void:
	_sound_effects.play_die()
