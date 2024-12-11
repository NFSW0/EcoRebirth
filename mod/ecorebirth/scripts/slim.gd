extends EcoEntity


func _physics_process(delta: float) -> void:
	if multiplayer.has_multiplayer_peer():
		if not is_multiplayer_authority():
			return
	var movement_vector = _get_movement_vector()
	var direction = movement_vector.normalized()
	var target_velocity = get_entity_data("max_speed", 125) * direction
	velocity = velocity.lerp(target_velocity,1 - exp(-delta * get_entity_data("acceleration_smoothing", 25)))
	move_and_slide()


## 获取移动方向
func _get_movement_vector():
	if multiplayer.has_multiplayer_peer():
		if not is_multiplayer_authority():
			return Vector2()
	var play_manager = get_tree().current_scene
	if play_manager.has_method("get_player"):
		var player:Node = play_manager.get_player()
		var player_position = player.get("position")
		var direction = Vector2()
		if player_position:
			direction = player_position - position
		return direction
	else:
		call_deferred("queue_free")
		return Vector2()
