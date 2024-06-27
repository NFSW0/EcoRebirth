class_name _AdjunctManager
extends Node
## 附益管理器 注册附益与效果 添加活动附益 结算活动附益
# 优化提示1:附益效果无需独立为Resource，它是独立且开放的，调用无限制，组合后定义为一个附益

var adjunct_library := {} # 附益库 {tag:AdjunctData}
var adjunct_effects := {} # 附益效果 {tag:Callable(self,active_adjunct)}
var active_adjuncts := [] # 活动附益 [AdjunctActive]

## 注册附益
func register_adjunct(resource_path):
	if not ResourceLoader.exists(resource_path):
		return
	var resource = load(resource_path)
	if not resource is AdjunctData:
		return
	var adjunct_tag:String = (resource as AdjunctData).tag
	if adjunct_library.has(adjunct_tag):
		return
	adjunct_library[adjunct_tag] = resource
	var message = "已注册附益: %s" % adjunct_tag # 生成日志信息
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志
## 获取附益
func get_adjunct(adjunct_tag:String) -> AdjunctData:
	if not adjunct_tag in adjunct_library.keys():
		return null
	return adjunct_library[adjunct_tag]

## 注册附益效果
func register_adjunct_effect(effect_tag: String, call_back: Callable):
	adjunct_effects[effect_tag] = call_back
	var message = "已注册附益效果: %s" % effect_tag # 生成日志信息
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志
## 获取附益效果
func get_adjunct_effect(effect_tag: String) -> Callable:
	if not effect_tag in adjunct_effects:
		return Callable()
	return adjunct_effects[effect_tag]

## 添加活动附益
func add_active_adjunct(active_adjunct: AdjunctActive):
	# 权限检查
	if multiplayer.has_multiplayer_peer():
		if not multiplayer.is_server():
			rpc_id(1, "_add_active_adjunct_by_dictionary", active_adjunct.to_dictionary())
			return
	_add_active_adjunct(active_adjunct)
## 获取目标活动附益
func get_target_active_adjuncts(target: Node) -> Array[AdjunctActive]:
	var result:Array[AdjunctActive] = []
	for active_adjunct:AdjunctActive in active_adjuncts:
		if active_adjunct.adjunct_target == target:
			result.append(active_adjunct)
	return result

## 活动附益生效
func tack_effect(active_adjunct: AdjunctActive, effect_time: String):
	var adjunct = get_adjunct(active_adjunct.adjunct_data_tag)
	if adjunct == null:
		return
	if not adjunct.effects.keys().has(effect_time):
		return
	var eff_tags = adjunct.effects[effect_time]
	for tag in eff_tags:
		get_adjunct_effect(tag).call(self, active_adjunct)

## 附益结算
func _physics_process(delta):
	if multiplayer.has_multiplayer_peer():
		if not multiplayer.is_server():
			return
	var index = active_adjuncts.size() -1
	while index >= 0:
		var active_adjunct:AdjunctActive = active_adjuncts[index]
		# 有效性检查
		if active_adjunct.adjunct_target == null:
			active_adjuncts.remove_at(index)
			continue
		active_adjunct.tick_remain -= delta
		active_adjunct.duration_remain -=delta
		if not active_adjunct.permanency and active_adjunct.duration_remain <= 0:
			if active_adjunct.stack > 1:
				tack_effect(active_adjunct, "dilation")
			else:
				tack_effect(active_adjunct, "end")
				active_adjuncts.remove_at(index)
		else:
			tack_effect(active_adjunct, "tick")
		index -= 1
## 重复附益检查 用于附益叠加判定
func _adjunct_duplication(active_adjunct: AdjunctActive) -> AdjunctActive:
	for active:AdjunctActive in active_adjuncts:
		if active.adjunct_data_tag == active_adjunct.adjunct_data_tag and active.adjunct_target == active_adjunct.adjunct_target and active.adjunct_source == active_adjunct.adjunct_source:
			return active
	return null
## 添加活动附益 用于多人添加附益
@rpc("any_peer")
func _add_active_adjunct_by_dictionary(active_adjunct_dictionary:Dictionary):
	var active_adjunct = AdjunctActive.new()
	active_adjunct.from_dictionary(self, active_adjunct_dictionary)
	_add_active_adjunct(active_adjunct)
## 添加活动附益 用于多人添加附益
func _add_active_adjunct(active_adjunct: AdjunctActive):
	# 权限检查
	if multiplayer.has_multiplayer_peer():
		if not multiplayer.is_server():
			return
	# 有效判定
	if not active_adjunct.adjunct_data_tag in adjunct_library.keys():
		return
	# 累加或新增
	var current_active_adjunct:AdjunctActive
	var duplicate_adjunct:AdjunctActive = _adjunct_duplication(active_adjunct)
	if duplicate_adjunct != null:
		current_active_adjunct = duplicate_adjunct
		current_active_adjunct.accumulate(active_adjunct)
		tack_effect(active_adjunct, "stacking") # 触发叠层回调
	else:
		current_active_adjunct = active_adjunct
		active_adjuncts.append(active_adjunct)
		tack_effect(active_adjunct, "begin") # 触发新增回调
	# 数据修正
	current_active_adjunct._check_and_correct(get_adjunct(active_adjunct.adjunct_data_tag))
