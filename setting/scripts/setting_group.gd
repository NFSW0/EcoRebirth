class_name SettingGroup
extends Resource
# 表示设置项的一个组/层级

var children = {} # 可以是SettingOption或SettingGroup

func add_option(path: PackedStringArray, option: SettingOption): # 添加选项
	var current_group = self # 设置当前分组是自己
	for i in range(path.size() - 1): # 遍历全部组名
		if not path[i] in current_group.children: # 如果没有同名组
			current_group.children[path[i]] = SettingGroup.new() # 新建组
		current_group = current_group.children[path[i]] # 递进一层分组
	if path[-1] in current_group.children: # 如果已注册同名选项
		var existing_option = current_group.children[path[-1]] # 获取底层选项数据
		if existing_option is SettingOption: # 如果是选项数据
			existing_option.merge_option(option.values, option.callbacks) # 合并选项数据
	else: # 如果没有同名选项
		current_group.children[path[-1]] = option # 添加新选项数据

func get_option(path: PackedStringArray): # 获取选项集合
	var current_element = self # 设置当前检索对象为自己
	for part in path: # 遍历全部组名
		if part in current_element.children: # 如果包含对应组名
			current_element = current_element.children[part] # 递进一次层级
	return current_element
