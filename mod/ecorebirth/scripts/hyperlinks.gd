class_name Hyperlinks
extends Control

@onready var github = %Github

func _ready():
	github.texture_normal = TextureManager.get_texture("GithubLogo")
	github.custom_minimum_size = Vector2i(20, 20) * ProjectSettings.get("gui/theme/default_theme_scale")

func _on_github_pressed():
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), "点击Github") # 输出日志

