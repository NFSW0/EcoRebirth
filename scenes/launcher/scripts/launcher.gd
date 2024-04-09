extends Control
# 项目启动器 注册资源 不使用资源 处理进入标题界面前的事件 完成资源注册后进入标题界面

# 音频和UI资源路径
var audio_resources = [
	{"name": "Focus", "bus":AudioManager.AudioBus.SFX, "path": "res://scenes/launcher/audio/Focus.ogg"},
	{"name": "Interaction", "bus":AudioManager.AudioBus.SFX, "path": "res://scenes/launcher/audio/Interaction.ogg"},
	{"name": "Negative", "bus":AudioManager.AudioBus.SFX, "path": "res://scenes/launcher/audio/Negative.ogg"},
	{"name": "Positive", "bus":AudioManager.AudioBus.SFX, "path": "res://scenes/launcher/audio/Positive.ogg"},
	{"name": "Warning", "bus":AudioManager.AudioBus.SFX, "path": "res://scenes/launcher/audio/Warning.ogg"},
]
var ui_resources = [
	{"name": "MainMenu", "path": "res://scenes/launcher/ui/main_menu.tscn", "callable":func(_requester):},
	{"name": "VersionNumber", "path": "res://scenes/launcher/ui/version_number.tscn", "callable":func(_requester):},
	{"name": "Hyperlinks", "path": "res://scenes/launcher/ui/hyperlinks.tscn", "callable":func(_requester):},
]
var texture_resource = [
	{"name": "GithubLogo", "path": "res://scenes/launcher/texture/GitHub_logo.png"},
]

var message_id =1 # 下一条消息编号 用于产生唯一名称
var message_duration =1 # 消息持续时间
var message_fade_time =0.5 # 消息淡出时间
var interval = 0.1 # 间隔

func _ready():
	await register_audio_resources() # 注册外部音频资源
	await register_ui_resources() # 注册外部UI资源
	await register_texture_resource() # 注册外部材质
	_enter_title_screen() # 进入标题屏

func register_audio_resources(): # 注册音频资源
	for audio in audio_resources:
		_add_message(audio["path"])
		if ResourceLoader.exists(audio["path"]):
			var audio_stream = load(audio["path"])
			AudioManager.register_audio(audio["name"], audio["bus"], audio_stream)
			await get_tree().create_timer(interval).timeout

func register_ui_resources(): # 注册UI资源
	for ui in ui_resources:
		_add_message(ui["path"])
		if ResourceLoader.exists(ui["path"]):
			var ui_scene = load(ui["path"])
			UIManager.register_ui(ui["name"], ui_scene, ui["callable"])
			await get_tree().create_timer(interval).timeout

func register_texture_resource(): # 注册材质
	for texture in texture_resource:
		_add_message(texture["path"])
		if ResourceLoader.exists(texture["path"]):
			var _texture = load(texture["path"])
			TextureManager.register_texture(texture["name"], _texture)
			await get_tree().create_timer(interval).timeout

func _add_message(label_text): # 显示加载信息
	# 添加Label
	var new_label = Label.new()
	new_label.text = label_text
	new_label.name = str(message_id)
	%LableBox.add_child(new_label)
	# 淡出Label
	message_id += 1
	var tween = new_label.create_tween()
	tween.tween_interval(message_duration)
	tween.tween_property(new_label, "self_modulate", Color.TRANSPARENT, message_fade_time)
	tween.tween_callback(new_label.queue_free)

func _enter_title_screen(): # 进入开始菜单(标题屏幕)
	get_tree().call_deferred("change_scene_to_file", "res://scenes/title_screen/scenes/title_screen.tscn")
