class_name SettingOption
extends Resource
# 表示单个设置项，支持存储多个值和回调

var name: String # 选项名称
var values = [] # 选项可用值集合
var callbacks = [] # 选项回调函数集合

func _init(_name: String, _values: Array, _callbacks: Array): # 构造设置选项数据
	name = _name
	values = _values
	callbacks = _callbacks

func merge_option(_values: Array, _callbacks: Array): # 合并相同路径的选项
	values += _values
	callbacks += _callbacks
