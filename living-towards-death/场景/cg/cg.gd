extends Node2D

@export_file("*.tscn") var path: String

func change_scene() -> void:
	Game.change_scene(path)
