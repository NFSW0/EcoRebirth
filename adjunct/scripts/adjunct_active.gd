class_name AdjunctActive
extends Resource
## 活动附益 正在生效的附益 参与附益结算
## 附益(标签) 目标 来源 是否永久 层数 已间歇次数 剩余间歇时间 剩余持续时间

var adjunct_data_tag: String
var adjunct_target: Node
var adjunct_source: Node
var permanency: bool
var stack: int
var tick_count: int
var tick_remain: float
var duration_remain: float

func _init(
	_adjunct_data_tag:String = "",
	_adjunct_target: Node = null,
	_adjunct_source: Node = null,
	_permanency: bool = false,
	_stack: int = 0,
	_tick_count: int = 0,
	_tick_remain: float = 0,
	_duration_remain: float = 0,
	):
	adjunct_data_tag = _adjunct_data_tag
	adjunct_target = _adjunct_target
	adjunct_source = _adjunct_source
	permanency = _permanency
	stack = _stack
	tick_count = _tick_count
	tick_remain = _tick_remain
	duration_remain = _duration_remain

func from_dictionary(requester:Node, dictionary:Dictionary):
	adjunct_data_tag = dictionary.get("adjunct_data_tag",adjunct_data_tag)
	adjunct_target = _get_node(requester, dictionary.get("adjunct_target",""))
	adjunct_source = _get_node(requester, dictionary.get("adjunct_source",""))
	permanency = dictionary.get("permanency",permanency)
	stack = dictionary.get("stack",stack)
	tick_count = dictionary.get("tick_count",tick_count)
	tick_remain = dictionary.get("tick_remain",tick_remain)
	duration_remain = dictionary.get("duration_remain",duration_remain)

func to_dictionary() -> Dictionary:
	var result = {
		"adjunct_data_tag":adjunct_data_tag,
		"adjunct_target":adjunct_target.get_path(),
		"adjunct_source":adjunct_source.get_path(),
		"permanency":permanency,
		"stack":stack,
		"tick_count":tick_count,
		"tick_remain":tick_remain,
		"duration_remain":duration_remain
	}
	return result

func _get_node(requester:Node, node_path:String):
	if node_path.is_empty():
		return adjunct_target
	var result = requester.get_node_or_null(node_path)
	if result == null:
		return adjunct_target
	return result
