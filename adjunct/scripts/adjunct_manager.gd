class_name _AdjunctManager
extends Node
## 附益管理器
## 注册附益
## 注册附益效果
## 添加活动附益
## 持续附益结算
## 指定附益结算

var adjunct_library = {} #{tag:AdjunctData}
var adjunct_effects = {} #{tag:Callable(self)}
var active_adjuncts = [] #[AdjunctActive]

## 注册附益
func register_adjunct(resource_path):
	if not ResourceLoader.exists(resource_path):
		return
	var resource = load(resource_path)
	if not resource is AdjunctData:
		return
	var adjunct_tag:String = (resource as AdjunctData).tag
	adjunct_library[adjunct_tag] = resource

## 获取附益
func get_adjunct(adjunct_tag:String) -> AdjunctData:
	return adjunct_library[adjunct_tag]

## 注册附益效果
func register_adjunct_effect(effect_tag:String, call_back:Callable):
	adjunct_effects[effect_tag] = call_back

## 添加活动附益
func add_active_adjunct(active_adjunct:AdjunctActive):
	active_adjuncts.append(active_adjunct)

## 获取目标活动附益
func get_target_active_adjuncts(target:Node) -> Array[AdjunctActive]:
	var result:Array[AdjunctActive] = []
	for active_adjunct:AdjunctActive in active_adjuncts:
		if active_adjunct.adjunct_target == target:
			result.append(active_adjunct)
	return result

## 附益生效
func tack_effect():
	pass

## Buff系统核心[自动加载]
## 处理逻辑:
## 无效判定:数据不存在 或 目标不存在
## 新建判定:来源不存在 或 无叠加目标
## 叠加判定:同数据、同目标、同来源时叠加层数和剩余持续时间，但无法超过最大值

## 在Buff添加后传出新Buff的信息
#signal new_buff_appended(buff_info:BuffInfo)

## 由服务器统一存储所有Buff信息方便同步
#var all_buffs : Array[BuffInfo] = []

## 附加Buff 因为存在直接附加Buff行为，所以为客户端提供方法
#@rpc("any_peer","call_local","reliable")
#func append_buff(buff_data_path:String,buff_target_id:int,buff_source_id:int=0,buff_permanent:bool=false,buff_stack:int=1):
	#if !multiplayer.is_server():
		#print("已取消即将在客户端处理的效果添加指令")
		#return
	#if buff_data_path.is_empty() or buff_target_id == 0:
		#print("已忽略无效的效果添加指令:")
		#print("数据路径:%s" % buff_data_path)
		#print("目标路径:%s" % buff_target_id)
	#else:
		#var buff_data:BuffData = load(buff_data_path)
		#var buff_target:Node = instance_from_id(buff_target_id)
		#if buff_data == null or buff_target == null:
			#print("已跳过目标缺失的效果添加指令:")
			#if buff_data == null:
				#print("效果数据缺失:%s" % buff_data_path)
			#if buff_target == null:
				#print("效果目标缺失:%s" % buff_target_id)
		#else:
			#var buff_info:BuffInfo = BuffInfo.new(buff_data.duplicate(),buff_target,null if buff_source_id == 0 else instance_from_id(buff_source_id),buff_permanent,buff_stack,0,buff_data.buff_tick_interval,buff_data.buff_max_duration)
			#var buff = _find_buff(buff_info)
			#if buff != null:
				#print("已叠加目标是 %s 的效果: %s" % [buff_info.buff_target.name, buff_info.buff_data.buff_name])
				#buff.current_duration_remain = min(buff.current_duration_remain + buff_info.current_duration_remain, buff_info.buff_data.buff_max_duration)
				#buff.current_stack = min(buff.current_stack + buff_info.current_stack, buff_info.buff_data.buff_max_stack)
			#else:
				#print("已新建目标是 %s 的效果: %s" % [buff_info.buff_target.name, buff_info.buff_data.buff_name])
				#all_buffs.append(buff_info)
				#_send_new_buff_info(buff_info)
			#if buff_info.buff_data.buff_effect_on_append != null:
				#print("已触发效果 %s 的附加事件" % buff_info.buff_data.buff_name)
				#for buff_effect in buff_info.buff_data.buff_effect_on_append:
					#buff_effect.apply(buff_info)

## 传出新Buff信息 仅服务端
#func _send_new_buff_info(buff_info):
	#new_buff_appended.emit(buff_info)

## 获取Buff 仅服务端
#func _find_buff(buff_info:BuffInfo) -> BuffInfo:
	#if buff_info.buff_source == null:
		#return null
	#for buff in all_buffs:
		#if buff.buff_target == buff_info.buff_target and buff.buff_source == buff_info.buff_source and buff.buff_data.buff_id == buff_info.buff_data.buff_id:
			#return buff
	#return null

## 结算Buff 仅服务端
#func _physics_process(delta):
	#if multiplayer.is_server():
		#var index:int = all_buffs.size() - 1
		#while index >= 0:
			## 间歇处理
			#if all_buffs[index].buff_data.buff_effect_on_tick != null and all_buffs[index].buff_data.buff_tick_interval > 0:
				#if all_buffs[index].current_tick_remain <= 0:
					#print("已触发效果 %s 的间歇事件" % all_buffs[index].buff_data.buff_name)
					#all_buffs[index].current_tick_count += 1
					#all_buffs[index].current_tick_remain = all_buffs[index].buff_data.buff_tick_interval
					#for buff_effect in all_buffs[index].buff_data.buff_effect_on_tick:
						#buff_effect.apply(all_buffs[index])
				#else:
					#all_buffs[index].current_tick_remain -= delta
			## 消除处理
			#if not all_buffs[index].buff_permanent:
				#all_buffs[index].current_duration_remain -= delta
			#if all_buffs[index].buff_target == null or all_buffs[index].current_duration_remain <= 0 or all_buffs[index].current_stack <= 0:
				#if all_buffs[index].buff_data.buff_effect_on_erase != null:
					#print("已触发效果 %s 的消除事件" % all_buffs[index].buff_data.buff_name)
					#for buff_effect in all_buffs[index].buff_data.buff_effect_on_erase:
						#buff_effect.apply(all_buffs[index])
				#all_buffs.remove_at(index)
			#index -= 1
