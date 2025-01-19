extends Area2D

@export_file("*.tscn") var self_path: String
@export_file("*.tscn") var path: String

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("replay"):
		Game.change_scene(self_path)

func _on_area_entered(area: Area2D) -> void:
	if area.name == "PlayerBody":
		Game.change_scene(path)
