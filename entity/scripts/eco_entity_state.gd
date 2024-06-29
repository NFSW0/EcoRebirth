class_name EcoEntityState
extends EcoEntityBase
# 状态实体 给实体划分多状态 不同状态不同处理逻辑 可降低性能损耗(剔除无关运算)

var state_library
var current_state

func _ready():
	super._ready()
	
	var data:Dictionary = entity.get_entity_data()
