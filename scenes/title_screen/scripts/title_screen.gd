class_name TitleScreen
extends Control

func _ready():
	UIManager.get_ui("MainMenu", self)
	UIManager.get_ui("Hyperlinks", self)
	UIManager.get_ui("VersionNumber", self)
