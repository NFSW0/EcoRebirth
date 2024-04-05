extends Control
# 项目启动器 处理进入标题界面前的事件 完成资源注册后进入标题屏

# 音频和UI资源路径
var audioResources = [
	{"name": "Focus", "bus":AudioManager.AudioBus.SFX, "path": "res://launcher/assets/Audio/Focus.ogg"},
	{"name": "Interaction", "bus":AudioManager.AudioBus.SFX, "path": "res://launcher/assets/Audio/Interaction.ogg"},
	{"name": "Negative", "bus":AudioManager.AudioBus.SFX, "path": "res://launcher/assets/Audio/Negative.ogg"},
	{"name": "Positive", "bus":AudioManager.AudioBus.SFX, "path": "res://launcher/assets/Audio/Positive.ogg"},
	{"name": "Warning", "bus":AudioManager.AudioBus.SFX, "path": "res://launcher/assets/Audio/Warning.ogg"},
]
var uiResources = [
	{"name": "TitleScreen", "path": "res://ui/TitleScreen.tscn", "callable":func():},
	{"name": "MainMenu", "path": "res://ui/MainMenu.tscn", "callable":func():},
]

var interval = 0.1

func _ready():
	await register_audio_resources()
	await register_ui_resources()
	enter_title_screen()

func register_audio_resources():
	for audio in audioResources:
		if ResourceLoader.exists(audio["path"]):
			var audio_stream = load(audio["path"])
			AudioManager.register_audio(audio["name"], audio["bus"], audio_stream)
			await get_tree().create_timer(interval).timeout

func register_ui_resources():
	for ui in uiResources:
		if ResourceLoader.exists(ui["path"]):
			var ui_scene = load(ui["path"])
			UIManager.register_ui(ui["name"], ui["callable"], ui_scene)
			await get_tree().create_timer(interval).timeout

func enter_title_screen():
	var titleScreen = UIManager.get_ui("TitleScreen", self)
	if titleScreen != null:
		titleScreen.show()
