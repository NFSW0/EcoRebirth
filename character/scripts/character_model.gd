extends EcoEntity

@onready var body = %Body
@onready var face = %Face

func _ready() -> void:
	super._ready() # 多人初始化 更新数据
	
	# 获取数据并初始化子节点 
	var character_data = get_entity_data()
	var body_texture = TextureManager.get_texture(character_data["body"])
	body.offset = Vector2(0, -body_texture.get_height() / 2)
	body.texture = body_texture
	face.texture = TextureManager.get_texture(character_data["face"])
	
	_end_ready()
func _end_ready():
	if multiplayer.has_multiplayer_peer():
		if not is_multiplayer_authority():
			return
	get_tree().current_scene.set_player(self) # 设置本机角色 用于动态更新或协调游玩场景

func _process(delta):
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
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_movement,y_movement /2)
