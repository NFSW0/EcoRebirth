class_name AdjunctData
extends Resource
## 附益数据 描述一个附益 不参与附益结算
## 名称 标签 {时机:[有序效果集]} 最大层数 最大持续时间 额外数据{图标...}

@export var name: String = "example"
@export var tag: String = "eco_rebirth:example"
@export var effects: Dictionary = {
"begin":["effect_name"], # 附益添加时
"tick":[], # 附益存在时
"end":[], # 附益结束时
"pre-attack":[], # 攻击前
"post-attack":[], # 攻击后
"post-hited":[], # 被命中后
"post-hit":[], # 命中后
"pre-harmed":[], # 被伤害前
"pre-harm":[], # 伤害前
"post-harmed":[], # 被伤害后
"post-harm":[], # 伤害后
}
@export var max_stack: int = 1
@export var max_duration: float = 10
@export var data: Dictionary = {}
