class_name Bird
extends CharacterBody2D

signal hit_obstacle
signal landed

enum State { HOVERING, FLYING, DEAD }

const HOVER_AMPLITUDE := 3.0
const HOVER_FREQUENCY := 3.0
const WING_FRAMES_PER_SECOND := 8.0
const FLAP_TILT := -PI / 8
const DIVE_TILT := PI / 2
const TILT_SPEED := 4.0
const GROUND_ONLY_COLLISION_MASK := 4

@export var skins: Array[Texture2D] = []

@onready var _sprite: Sprite2D = $Sprite2D

var _state := State.HOVERING
var _hover_origin_y := 0.0
var _elapsed := 0.0


func _ready() -> void:
	position.x = get_viewport_rect().size.x * GameConfig.BIRD_SCREEN_FRACTION_X
	_hover_origin_y = position.y
	_sprite.texture = skins.pick_random()


func _physics_process(delta: float) -> void:
	_elapsed += delta
	match _state:
		State.HOVERING:
			_hover()
			_animate_wings()
		State.FLYING:
			_fall(delta)
			_animate_wings()
			_tilt_toward_velocity(delta)
		State.DEAD:
			_fall(delta)
			_tilt_toward_velocity(delta)


func start_flying() -> void:
	_state = State.FLYING


func flap() -> void:
	velocity.y = GameConfig.FLAP_VELOCITY
	rotation = FLAP_TILT


func _hover() -> void:
	position.y = _hover_origin_y + sin(_elapsed * HOVER_FREQUENCY) * HOVER_AMPLITUDE


func _animate_wings() -> void:
	_sprite.frame = int(_elapsed * WING_FRAMES_PER_SECOND) % _sprite.hframes


func _fall(delta: float) -> void:
	velocity.y = minf(velocity.y + GameConfig.GRAVITY * delta, GameConfig.MAX_FALL_SPEED)
	var collision := move_and_collide(velocity * delta)
	_keep_below_ceiling()
	if collision:
		_on_collided()


func _keep_below_ceiling() -> void:
	if position.y < 0.0:
		position.y = 0.0
		velocity.y = 0.0


func _tilt_toward_velocity(delta: float) -> void:
	if velocity.y > 0.0:
		rotation = move_toward(rotation, DIVE_TILT, TILT_SPEED * delta)


func _on_collided() -> void:
	if _state == State.DEAD:
		_land()
	else:
		_die()


func _die() -> void:
	_state = State.DEAD
	velocity.y = 0.0
	collision_mask = GROUND_ONLY_COLLISION_MASK
	hit_obstacle.emit()


func _land() -> void:
	set_physics_process(false)
	landed.emit()
