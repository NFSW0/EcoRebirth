extends RefCounted
class_name DataTool

static func parse_vector2i(input_str: String) -> Vector2i:
	# 去掉两边的括号和空格
	var trimmed_str = input_str.replace("(","").replace(")","").strip_edges()
	
	# 通过逗号分割字符串
	var components = trimmed_str.split(",")
	
	# 确保有两个部分
	if components.size() != 2:
		return Vector2i()
	
	# 转换每个部分为整数
	var x = int(components[0])
	var y = int(components[1])
	
	# 返回 Vector2i 对象
	return Vector2i(x, y)
