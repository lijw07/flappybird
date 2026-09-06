extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const SCREENSHOT_DIR := "res://build/screenshots"
const TARGET_PIPES := 12
const MAX_FRAMES := 3000
const FLAP_BELOW_TARGET_OFFSET := 6.0

var _main: Node
var _bird: Bird
var _pipe_spawner: PipeSpawner
var _frame := 0
var _pipes_passed := 0
var _landed := false


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SCREENSHOT_DIR))
	_main = load(MAIN_SCENE).instantiate()
	root.add_child(_main)
	_bird = _main.get_node("Bird")
	_pipe_spawner = _main.get_node("PipeSpawner")
	_pipe_spawner.pipe_passed.connect(func() -> void: _pipes_passed += 1)
	_bird.landed.connect(func() -> void: _landed = true)


func _process(_delta: float) -> bool:
	_frame += 1
	if _frame == 5:
		_capture("ready")
	if _frame == 10:
		_press_flap()
	elif _frame > 10 and _pipes_passed < TARGET_PIPES:
		_autopilot()
	if _frame == 260:
		_capture("playing")
	if _landed:
		return _finish()
	return _frame >= MAX_FRAMES


func _autopilot() -> void:
	if _bird.velocity.y > 0.0 and _bird.position.y > _target_y() + FLAP_BELOW_TARGET_OFFSET:
		_press_flap()


func _target_y() -> float:
	var upcoming := _upcoming_pipe_pair()
	return upcoming.position.y if upcoming else GameConfig.GROUND_TOP_Y / 2.0


func _upcoming_pipe_pair() -> PipePair:
	var nearest: PipePair = null
	for child in _pipe_spawner.get_children():
		var is_ahead: bool = child is PipePair and child.position.x > _bird.position.x - 20.0
		if is_ahead and (nearest == null or child.position.x < nearest.position.x):
			nearest = child
	return nearest


func _press_flap() -> void:
	var event := InputEventAction.new()
	event.action = "flap"
	event.pressed = true
	Input.parse_input_event(event)


func _capture(name: String) -> void:
	var image := root.get_viewport().get_texture().get_image()
	image.save_png("%s/%s.png" % [SCREENSHOT_DIR, name])


func _finish() -> bool:
	_capture("game_over")
	var hud := _main.get_node("Hud")
	print("RESULT pipes_passed=%d frames=%d hud=%s best=%s medal_visible=%s" % [
		_pipes_passed, _frame,
		hud.get_node("GameOverPanel/FinalScoreLabel").text,
		hud.get_node("GameOverPanel/BestScoreLabel").text,
		hud.get_node("GameOverPanel/MedalIcon").visible])
	return true
