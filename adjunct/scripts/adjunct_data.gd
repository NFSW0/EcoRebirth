class_name AdjunctData
extends Resource
## 附益数据 描述一个附益 不参与附益结算
## 名称 标签 {时机:[有序效果集]} 最大层数 最大持续时间 额外数据{图标...}

@export var name: String = "debug"
@export var tag: String = "eco_rebirth:debug"
@export var effects: Dictionary = { # 影响效果字典 无需划分父子类
"stacking":["eco_rebirth:debug_stacking"], # 附益叠加时
"dilation":["eco_rebirth:debug_end"], # 附益削减时
"begin":["eco_rebirth:debug_begin"], # 附益添加时
"tick":["eco_rebirth:debug_tick"], # 附益存在时
"end":["eco_rebirth:debug_end"], # 附益结束时
"pre-attack":["eco_rebirth:debug_end"], # 攻击前
"post-attack":["eco_rebirth:debug_end"], # 攻击后
"post-hited":["eco_rebirth:debug_end"], # 被命中后
"post-hit":["eco_rebirth:debug_end"], # 命中后
"pre-harmed":["eco_rebirth:debug_end"], # 被伤害前
"pre-harm":["eco_rebirth:debug_end"], # 伤害前
"post-harmed":["eco_rebirth:debug_end"], # 被伤害后
"post-harm":["eco_rebirth:debug_end"], # 伤害后
}
@export var max_stack: int = 1
@export var max_duration: float = 10
@export var data: Dictionary = {}
