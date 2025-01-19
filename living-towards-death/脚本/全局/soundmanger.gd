extends Node

enum Bus { MASTER, SFX, BGM }

@onready var sfx: Node = $SFX
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

func play_sfx(name: String) -> void:
	var player := sfx.get_node(name) as AudioStreamPlayer
	if not player:
		return
	player.play()

func stop_sfx(name: String) -> void:
	var player := sfx.get_node(name) as AudioStreamPlayer
	if not player:
		return
	player.stop()

func play_bgm(stream: AudioStream) -> void:
	if bgm_player.stream == stream and bgm_player.playing:
		return
	bgm_player.stream = stream
	bgm_player.play()

func stop_bgm(stream: AudioStream) -> void:
	if bgm_player.stream == stream and bgm_player.playing:
		return
	bgm_player.stream = stream
	bgm_player.stop()

func setup_ui_sounds(node: Node) -> void:
	var button := node as Button
	if button:
		button.pressed.connect(play_sfx.bind("UIPress"))
		button.focus_entered.connect(play_sfx.bind("UIFocus"))
		button.mouse_entered.connect(button.grab_focus)
	
	var slider := node as Slider
	if slider:
		slider.value_changed.connect(play_sfx.bind("UIPress").unbind(1))
		slider.focus_entered.connect(play_sfx.bind("UIFocus"))
		slider.mouse_entered.connect(slider.grab_focus)
	
	for child in node.get_children():
		setup_ui_sounds(child)
