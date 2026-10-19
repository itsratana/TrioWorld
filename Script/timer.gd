extends Node

@export var time: float = 0
@export var minute: float = 0
@export var hour: float = 0
@export var second: float = 0
@export var msec: float = 0

@onready var player = $"../Player"
var formatted_time: String
var has_updated_score := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.toUpdateData:
		var score_as_int = int(hour * 3600000 + minute * 60000 + second * 1000 + msec * 10) * (-1)
		if not has_updated_score:
			GameManager.highscore_global = score_as_int
			GameManager.update_player_stats_to_playfab(true)
			has_updated_score = true
		return
	
	if player.hasStartMove:
		time += delta
		#msec = fmod(time, 1) * 100
		#second = fmod(time, 60)
		#minute = fmod(time, 3600) / 60
		var total_ms = int(time * 1000)

		hour = total_ms / 3600000
		minute = (total_ms % 3600000) / 60000
		second = (total_ms % 60000) / 1000
		msec = (total_ms % 1000) / 10  # For 2-digit display
	
	formatted_time = "%01dH %01dM %01dS %01dMS" % [hour, minute, second, msec]
	
	$"../Control/CanvasLayer/Time/Hour".text = "%02d:" % hour
	$"../Control/CanvasLayer/Time/Minute".text = "%02d:" % minute
	$"../Control/CanvasLayer/Time/Second".text = "%02d:" % second
	$"../Control/CanvasLayer/Time/Mil Sec".text = "%02d" % msec
