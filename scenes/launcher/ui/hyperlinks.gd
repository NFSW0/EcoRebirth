class_name Hyperlinks
extends Control

@onready var github = %Github

func _on_github_pressed():
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), "点击Github") # 输出日志

