extends CharacterBody2D

var character_data = {"body":"Body1", "face":"Face1"}
@onready var body = %Body
@onready var face = %Face

func _ready() -> void:
	if multiplayer.is_server():
		_init_character_data(character_data)
	else:
		rpc_id(1, "_send_character_data")

## 服务端-发送特效数据
@rpc("any_peer", "reliable")
func _send_character_data():
	var sender_id = multiplayer.get_remote_sender_id()
	rpc_id(sender_id, "_init_character_data", character_data)

## 属性赋值
@rpc("reliable")
func _init_character_data(_character_data):
	character_data = _character_data
	body.texture = TextureManager.get_texture(character_data["body"])
	face.texture = TextureManager.get_texture(character_data["face"])
