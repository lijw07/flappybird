class_name ScrollingBackdrop
extends Node2D

@export var background_textures: Array[Texture2D] = []

@onready var _background_layer: Parallax2D = $BackgroundLayer
@onready var _background_sprite: Sprite2D = $BackgroundLayer/Sprite2D
@onready var _ground_layer: Parallax2D = $GroundLayer
@onready var _ground_sprite: Sprite2D = $GroundLayer/Sprite2D


func _ready() -> void:
	_background_sprite.texture = background_textures.pick_random()
	get_viewport().size_changed.connect(_cover_visible_width)
	_cover_visible_width()
	start()


func start() -> void:
	_background_layer.autoscroll.x = -GameConfig.SCROLL_SPEED * GameConfig.BACKGROUND_PARALLAX_FACTOR
	_ground_layer.autoscroll.x = -GameConfig.SCROLL_SPEED


func stop() -> void:
	_background_layer.autoscroll = Vector2.ZERO
	_ground_layer.autoscroll = Vector2.ZERO


func _cover_visible_width() -> void:
	var visible_width := get_viewport_rect().size.x
	_tile_across(_background_sprite, visible_width)
	_tile_across(_ground_sprite, visible_width)


static func _tile_across(sprite: Sprite2D, visible_width: float) -> void:
	var tile_size := sprite.texture.get_size()
	var tile_count := ceili(visible_width / tile_size.x) + 1
	sprite.region_rect = Rect2(0.0, 0.0, tile_count * tile_size.x, tile_size.y)
