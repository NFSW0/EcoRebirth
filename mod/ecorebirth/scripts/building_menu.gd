extends Control
class_name BuildingMenu


@onready var content = %Content


func _on_button_pressed() -> void:
	content.visible = !content.visible


func _on_null_pressed() -> void:
	get_tree().current_scene.enter_building_model()


func _on_stone_pressed() -> void:
	get_tree().current_scene.enter_building_model(1, Vector2i(0,0))


func _on_tree_pressed() -> void:
	get_tree().current_scene.enter_building_model(1, Vector2i(1,0))
