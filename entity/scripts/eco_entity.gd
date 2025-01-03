class_name EcoEntity
extends CharacterBody2D
# 多人实体父类 实现数据的多人初始化功能

var entity_data := {}
func set_entity_data(_entity_data: Dictionary):
	entity_data = _entity_data
func get_entity_data(key = "", normal = null):
	if key.is_empty():
		return entity_data
	if not entity_data.has(key):
		return normal
	return entity_data[key]

# 这里的初始化为自定义实体服务(未投入使用)，场景预制体无法使用
func _init(_entity_data = {}):
	entity_data = _entity_data

func _ready():
	_multi_ready()

#region 多人初始化
func _multi_ready():
	if multiplayer.has_multiplayer_peer():
		if not multiplayer.is_server():
			rpc_id(1, "_send_entity_data")
			return
	_init_entity_data(entity_data)

@rpc("any_peer", "reliable")
func _send_entity_data():
	var sender_id = multiplayer.get_remote_sender_id()
	rpc_id(sender_id, "_init_entity_data", entity_data)

@rpc("any_peer", "reliable")
func _init_entity_data(_entity_data):
	entity_data = _entity_data
	if _entity_data is Dictionary:
		for key in _entity_data.keys():
			if typeof(get(key)) == typeof(_entity_data[key]):
				set(key, _entity_data[key])
	if multiplayer.has_multiplayer_peer():
		if not multiplayer.is_server():
			rpc("_completed_init")
			return
	_completed_init()

@rpc("any_peer","reliable","call_local")
func _completed_init():
	set("visible", true)
#endregion 多人初始化
