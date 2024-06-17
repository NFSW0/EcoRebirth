extends EcoEntity

@onready var body = %Body
@onready var face = %Face

func _ready() -> void:
	super._ready() # 多人初始化 更新数据
	
	var character_data = get_entity_data() # 获取数据并初始化
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
