class_name LogAccess
extends RefCounted
## 日志处理器 自定义日志处理

enum LogLevel {DEBUG, INFO, WARNING, ERROR, CRITICAL} ## 日志级别(不重要(低) -> 重要(高))

const LOG_FILE_PATH : String = "user://log.txt" ## 日志文件路径

var log_to_file : bool = false ## 是否写入日志文件
var current_level : LogLevel = LogLevel.DEBUG ## 设定的日志级别，如果即将输出的日志级别低于设定级别，则不会输出

func log_message(level: LogLevel, type_name: String, message: String): ## 输出日志
	if level < current_level: ## 如果日志级别低于设定级别
		return ## 忽略此次日志记录
	var date = Time.get_datetime_string_from_system() ## 获取日期
	var final_message = "[%s] [%s] <%s> : %s" % [date, level, type_name, message] ## 生成日志信息
	if log_to_file: ## 如果写入日志文件
		var log_directory_path = LOG_FILE_PATH.get_base_dir() ## 获取日志目录路径
		if not DirAccess.dir_exists_absolute(log_directory_path): ## 如果数据目录不存在
			DirAccess.make_dir_recursive_absolute(log_directory_path) ## 创建完整数据目录
		var file = FileAccess.open(LOG_FILE_PATH,FileAccess.READ_WRITE) ## 打开日志文件
		file.store_line(final_message) ## 在末尾添加日志记录
	else: ## 如果不写入日志文件
		if level > 2:
			printerr(final_message) ## 将错误信息输出到控制台
		else: 
			print(final_message) ## 将信息输出到控制台

func set_log_level(level: LogLevel): ## 设置日志级别
	current_level = level ## 设置日志级别
