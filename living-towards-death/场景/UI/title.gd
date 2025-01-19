extends Control

@export_file("*.tscn") var path: String
@export var bgm: AudioStream 
@onready var level: Control = $level
@onready var main: Control = $main

func _on_start_pressed() -> void:
	if bgm:
		Soundmanger.play_bgm(bgm)
	Game.change_scene(path)
	Soundmanger.setup_ui_sounds(self)


func _on_level_pressed() -> void:
	main.hide()
	level.show()

func _on_one_pressed() -> void:
	Game.change_scene("res://场景/level/level_1.tscn")

func _on_two_pressed() -> void:
	Game.change_scene("res://场景/level/level_2.tscn")

func _on_three_pressed() -> void:
	Game.change_scene("res://场景/level/level_3.tscn")

func _on_four_pressed() -> void:
	Game.change_scene("res://场景/level/level_4.tscn")

func _on_five_pressed() -> void:
	Game.change_scene("res://场景/level/level_5.tscn")

func _on_six_pressed() -> void:
	Game.change_scene("res://场景/level/level_6.tscn")

func _on_re_pressed() -> void:
	level.hide()
	main.show()
