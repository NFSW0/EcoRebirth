class_name MessageBox
extends Control

var message_id =1 ## 下一条消息编号(产生唯一名称)
var message_duration =3 ## 消息持续时间
var message_fade_time =1 ## 消息淡出时间

func send_message(text):
	# 添加Label
	var new_label = Label.new()
	new_label.text = text
	new_label.name = str(message_id)
	$VBoxContainer.add_child(new_label)
	# 淡出Label
	message_id += 1
	var tween = new_label.create_tween()
	tween.tween_interval(message_duration)
	tween.tween_property(new_label, "self_modulate", Color.TRANSPARENT, message_fade_time)
	tween.tween_callback(new_label.queue_free)
