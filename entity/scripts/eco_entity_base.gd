class_name EcoEntityBase
extends EcoEntity
# 实体装饰类 _ready为装饰方法 EcoEntity本应是接口以保证方法统一

var entity:EcoEntity

func _init(_entity:EcoEntity):
	entity = _entity

func _ready():
	if entity.has_method("_ready"):
		entity._ready()
