class_name ArchiveData
extends Resource
# 存档数据 魔法球样式(与难度挂钩) 环境集合 存档种子 轮回周期等

enum ArchiveDifficulty{EAZY, DEFAULT, HARD}
enum ArchiveCircleTime{SHORT, DEFAULT, LONG}

var archive_name: String = "" # 存档名称
var archive_seed: int = randi_range(0,10000) # 存档种子
var archive_difficulty: ArchiveDifficulty = ArchiveDifficulty.DEFAULT # 难度-与魔法球样式有关联
var archive_cycle_time: ArchiveCircleTime = ArchiveCircleTime.DEFAULT # 周期时长
