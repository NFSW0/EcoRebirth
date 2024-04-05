class_name _AudioManager
extends Node
# 音频管理器 仅会在本地使用 无需多人RPC 依赖数据管理器

enum AudioBus{BGM, SFX} # 音频线道

var audio_resources := {} # 存储注册的音频资源

func register_audio(audio_name: String, audio_bus: AudioBus, audio_stream: AudioStream) -> String: # 注册音频资源
	var final_name = audio_name # 存储最终注册的名称
	var count = 1 # 用于循环改进名称
	while final_name in audio_resources: # 如果名称重复
		final_name = "%s_%d" % [audio_name, count] # 改进名称
		count += 1 # 循环变量
	audio_resources[final_name] = {"bus": str(audio_bus), "audio_stream": audio_stream} # 注册音频
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), "已注册音频:%s %s" % [final_name, audio_resources[final_name]]) # 输出日志
	return final_name # 返回最终注册的名称

func play_audio(audio_name: String) -> Node: # 播放音频
	if audio_name in audio_resources: # 如果音频已注册
		var audio_data: Dictionary = audio_resources.get(audio_name) # 获取音频数据
		var audio_stream: AudioStream = audio_data["audio_stream"] # 获取音频流
		var audio_bus: StringName = audio_data["bus"] # 获取音频线道
		var audio_player = AudioStreamPlayer.new() # 新建音频播放器
		audio_player.set_stream(audio_stream) # 设置音频流
		audio_player.set_bus(audio_bus) # 设置音频线道
		audio_player.set_autoplay(true) # 设置自动播放
		add_child(audio_player) # 添加实例
		audio_player.connect("finished",func():audio_player.queue_free()) # 设置自动释放
		return audio_player # 返回播放器实例
	else:
		var message = "(音频缺失)Error: Audio resource '%s' not found." % audio_name # 生成错误信息
		LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 输出日志
		return null
