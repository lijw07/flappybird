class_name SoundEffects
extends Node

@onready var _flap: AudioStreamPlayer = $Flap
@onready var _point: AudioStreamPlayer = $Point
@onready var _hit: AudioStreamPlayer = $Hit
@onready var _die: AudioStreamPlayer = $Die


func play_flap() -> void:
	_flap.play()


func play_point() -> void:
	_point.play()


func play_hit() -> void:
	_hit.play()


func play_die() -> void:
	_die.play()
