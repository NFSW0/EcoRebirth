class_name _EcoMultiSpawner
extends MultiplayerSpawner
# 多人生成器 用于同步生成节点
# data应包含resource_path指向PackedScene目标
# 目标应继承自EcoEntity
# data应避免包含sender_id，否则sender_id的内容会被覆盖

var unique_id: int = 0 # 用于产生唯一名称
var data_queue: Array = [] # 记录队列长度

func generate_entity(data):
	rpc_id(1,"_rpc_generate_entity",data)

func generate_entity_immediately(data):
	rpc_id(1,"_rpc_generate_entity_immediately",data)

@rpc("any_peer","call_local","reliable")
func _rpc_generate_entity(data):
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id() # 获取请求端ID
		data["sender_id"] = sender_id # 补充生成数据
		data_queue.append(data)

@rpc("any_peer","call_local","reliable")
func _rpc_generate_entity_immediately(data):
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id() # 获取请求端ID
		data["sender_id"] = sender_id # 补充生成数据
		spawn(data)

func _ready():
	spawn_path = self.get_path()
	spawn_function = _generate_entity # 设置多人生成方法

func _physics_process(_delta):
	if data_queue.is_empty():
		return
	spawn(data_queue.pop_front())

func _get_unique_name() -> String:
	unique_id += 1
	return str(unique_id)

func _generate_entity(data) -> Node:
	# 实例化节点
	var resource = load(data["resource_path"])
	if not resource is PackedScene:
		return null
	if not resource.can_instantiate():
		return null
	var node_instance = (resource as PackedScene).instantiate()
	
	# 设置节点名称 用于属性同步
	node_instance.name = _get_unique_name()
	
	# 设置节点初始化数据
	if node_instance.has_method("set_entity_data"):
		node_instance.set_entity_data(data)
	
	# 设置多人控制权限
	(node_instance as Node).set_multiplayer_authority(data["sender_id"])
	return node_instance
