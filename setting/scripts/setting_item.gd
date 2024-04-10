class_name SettingItem
extends Resource

var path: String
var type: Variant.Type
var value: Variant

func _init(_path: String, _type: Variant.Type, _value: Variant):
	path = _path
	type = _type
	value = _value
