class_name _TextureManager
extends Node
# 材质管理器 仅会在本地使用

var texture_resources := {} # 存储注册的材质资源
var textures_tagkey := {} # 存储按标签分类材质集合

func register_texture(texture_name: String, texture_path: Texture, texture_tag: String = "none") -> String: # 注册材质
	var final_name = _generate_final_name(texture_name) # 生成唯一名称
	texture_resources[final_name] = texture_path # 注册材质
	textures_tagkey[texture_tag] = textures_tagkey[texture_tag] + [texture_name] if textures_tagkey.has(texture_tag) else [texture_name] # 按标签分类的材质名
	var message = "已注册材质: %s" % final_name # 生成日志信息
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志
	return final_name # 返回最终注册的名称

func get_texture(texture_name: String) -> Texture: # 获取材质
	if texture_name in texture_resources: # 如果材质已注册
		return texture_resources[texture_name] # 返回材质资源
	else: # 如果材质未注册
		var message = "(材质缺失)Error: Texture resource '%s' not found." % texture_name # 生成错误信息
		LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), message) # 记录错误日志
		return null # 返回空

func get_textures_by_tag(texture_tag: String) -> Array[String]: # 获取对应标签的材质名集合
	if texture_tag in textures_tagkey: # 如果材质标签已注册
		return textures_tagkey[texture_tag]
	return []

func _generate_final_name(texture_name: String) -> String: # 生成唯一名称
	var final_name = texture_name # 存储最终注册的名称
	var count = 1 # 用于循环改进名称
	while final_name in texture_resources: # 如果名称重复
		final_name = "%s_%d" % [texture_name, count] # 改进名称
		count += 1 # 循环变量
	return final_name # 返回最终注册的名称
