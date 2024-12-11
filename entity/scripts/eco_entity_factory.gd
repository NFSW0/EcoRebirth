class_name _EcoEntityFactory
extends Node
# 实体工厂 传入实体名称 返回实体节点(未添加至场景)

var entity_library := {}

func register_entity(entity_name:String, data:Dictionary):
	entity_library[entity_name] = data
	var message = "已注册实体: %s" % entity_name # 生成日志信息
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志


func new_entity(entity_name):
	return entity_library[entity_name]
