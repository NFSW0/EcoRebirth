class_name _AudioManager
extends Node
# 音频管理器 仅会在本地使用 无需多人RPC 依赖数据管理器

enum AudioBus {BGM, SFX} # 音频线道
var audio_resources := {} # 存储注册的音频资源

func register_audio(audio_name: String, audio_bus: AudioBus, audio_stream: AudioStream) -> String: # 注册音频
	var final_name = _generate_final_name(audio_name) # 生成唯一名称
	var bus_name = _get_bus_name(audio_bus) # 获取线道名称
	audio_resources[final_name] = {"bus": bus_name, "audio_stream": audio_stream} # 注册音频
	var message = "已注册音频: %s %s" % [final_name, audio_resources[final_name]] # 生成日志信息
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志
	return final_name # 返回最终注册的名称

func play_audio(audio_name: String) -> Node: # 播放音频
	if audio_name in audio_resources: # 如果音频已注册
		var audio_data: Dictionary = audio_resources[audio_name] # 获取音频数据
		var audio_stream: AudioStream = audio_data["audio_stream"] # 获取音频流
		var audio_bus: StringName = audio_data["bus"] # 获取音频线道
		return _initialize_and_play(audio_stream, audio_bus) # 初始化并播放音频并返回节点
	else: # 如果音频未注册
		var message = "(音频缺失)Error: Audio resource '%s' not found." % audio_name # 生成错误信息
		LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), message) # 记录错误日志
		return null # 返回空

func _generate_final_name(audio_name: String) -> String: # 生成唯一名称
	var final_name = audio_name # 存储最终注册的名称
	var count = 1 # 用于循环改进名称
	while final_name in audio_resources: # 如果名称重复
		final_name = "%s_%d" % [audio_name, count] # 改进名称
		count += 1 # 循环变量
	return final_name # 返回最终注册的名称

func _get_bus_name(audio_bus: AudioBus) -> StringName: # 获取音频线道名
	match audio_bus: # 比较枚举
		AudioBus.BGM: return "BGM" # 返回背景音乐线道名
		AudioBus.SFX: return "SFX" # 返回音效线道名
		_: return "Master" # 默认返回主线道名

func _initialize_and_play(audio_stream: AudioStream, audio_bus: StringName) -> Node: # 初始化并播放音频并返回节点
	var audio_player = AudioStreamPlayer.new() # 新建播放器
	audio_player.set_stream(audio_stream) # 设定音频流
	audio_player.set_bus(audio_bus) # 设定音频线道
	audio_player.set_autoplay(true) # 设置自动播放
	add_child(audio_player) # 添加进场景
	audio_player.connect("finished",func():audio_player.queue_free()) # 设置自动释放
	return audio_player # 返回播放器节点
