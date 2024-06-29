class_name _EcoEntityFactory
extends Node
# 实体工厂 传入实体名称 返回实体节点(未添加至场景)

var entity_library := {}

func new_entity(_entity_name) -> Node:
	return EcoEntityState.new(EcoEntity.new({}))
