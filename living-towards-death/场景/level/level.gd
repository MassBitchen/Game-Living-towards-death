extends Node2D

@export_file("*.tscn") var self_path: String
@export var num :int
@export var bgm: AudioStream 

@onready var label: Label = $Label

func _ready() -> void:
	if bgm:
		Soundmanger.play_bgm(bgm)
	Game.num = num

func _physics_process(delta: float) -> void:
	if Game.num == 0:
		Game.change_scene(self_path)
	label.text = str("safe:") + str(Game.num)
