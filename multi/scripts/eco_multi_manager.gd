class_name _EcoMultiManager
extends Node
# 多人管理器 主要负责处理服务器与客户端的连接或断开逻辑

const main_scene_path = "res://scenes/main/scenes/main.tscn" # 主场景路径
const play_scene_path = "res://scenes/play/scenes/play.tscn" # 游玩场景路径

func _ready():
	# 仅在客户端上发出
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)
	# 其他客户端会收到通知 包括作为服务器的客户端
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)

func _connected_to_server():
	var message = "服务器连接成功"
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志
	get_tree().change_scene_to_file(play_scene_path) # 进入游玩场景

func _connection_failed():
	var message = "服务器连接失败"
	LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), message) # 记录日志
	get_tree().change_scene_to_file(main_scene_path) # 返回标题菜单

func _server_disconnected():
	var message = "从服务器断开"
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志
	get_tree().change_scene_to_file(main_scene_path) # 返回标题菜单

func _peer_connected(id):
	var message = "%s 已加入服务器" % id
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志

func _peer_disconnected(id):
	var message = "%s 已离开服务器" % id
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志
	# 清理有关实体
	var spawn_node = get_node(EcoMultiSpawner.get_spawn_path())
	for child in spawn_node.get_children():
		if child.name.begins_with(str(id)):
			child.queue_free()
