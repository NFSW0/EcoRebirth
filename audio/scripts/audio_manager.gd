class_name _AudioManager
extends Node
# 音频管理器 仅会在本地使用 无需多人RPC 依赖数据管理器

enum AudioBus{BGM, SFX} # 音频线道

var audio_resources := {} # 存储注册的音频资源

# 初始化 应用设置 设置数据全局访问
func _init():
	# 清理数据
	_cancel_all_audio()
	# 设置频道音量
	AudioServer.set_bus_volume_db(1,1)
	# 设置频道静音
	AudioServer.set_bus_mute(1,true)

# 判断名称可用
func name_available(unique_name: String) -> bool:
	return not audio_resources.has(unique_name) # 如果名称不唯一则返回false

# 注册音频资源
func register_audio(audio_name: String, audio_bus: AudioBus, audio_stream: AudioStream):
	if audio_name not in audio_resources:
		var bus = &"BGM" if audio_bus == AudioBus.BGM else &"SFX"
		audio_resources[audio_name] = {"bus": bus, "audio_stream": audio_stream}
	else:
		var message = "(重复注册音频-已忽略)Warning: Audio resource '%s' already exists." % audio_name # 生成错误信息
		LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 输出日志

# 播放音频
func play_audio(audio_name: String):
	if audio_name in audio_resources:
		var audio_data: Dictionary = audio_resources.get(audio_name)
		var audio_stream: AudioStream = audio_data["audio_stream"]
		var audio_bus: StringName = audio_data["bus"]
		var audio_player = AudioStreamPlayer.new()
		audio_player.set_stream(audio_stream)
		audio_player.set_bus(audio_bus)
		audio_player.set_autoplay(true)
		add_child(audio_player)
		audio_player.connect("finished",func():audio_player.queue_free()) # 自动释放
	else:
		var message = "(音频缺失)Error: Audio resource '%s' not found." % audio_name # 生成错误信息
		LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 输出日志

# 注销所有音频
func _cancel_all_audio():
	audio_resources.clear()
