extends Control
@export var level_unlocks: Array[bool] = [true, false]
@export var level_scenes: Array[String] = [
	"res://Scene Level/Level 1.tscn",
	"res://Scene Level/Level 2.tscn"
]
@export var levels:Array[Sprite2D]
@export var current_index = 0

@onready var leaderboard = $Leaderboard
@onready var closeLeaderboard = $Leaderboard/CloseButton

@onready var playButton = $"HomeScreen/Play Panel"

@onready var userName = $NameBar/Group3/Username
var GM: GameManager = GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_music("MainMenu")
	userName.text = GM.UserName

func update_level_display() -> void:
	for level in levels:
		level.visible = false
	
	levels[current_index].visible = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_coins_ui()

func update_coins_ui() -> void:
	$NameBar/Coin/Coin.text = "%d" % GameManager.coin_global

#func _on_arrow_next_released() -> void:
	#if current_index < levels.size() -1:
		#current_index += 1
		#update_level_display()

#func _on_arrow_prev_released() -> void:
	#if current_index > 0:
		#current_index -= 1
		#update_level_display()

#func _on_play_panel_released() -> void:
	#if not level_unlocks[current_index]:
		#print("Level is locked!")
		#return

func _on_arrow_next_pressed() -> void:
	if current_index < levels.size() -1:
		current_index += 1
		update_level_display()

func _on_arrow_prev_pressed() -> void:
	if current_index > 0:
		current_index -= 1
		update_level_display()

func _on_play_panel_pressed() -> void:
	if not level_unlocks[current_index]:
		print("Level is locked!")
		return
		
	var selected_level = level_scenes[current_index]
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file(selected_level)

#func _on_leaderboard_released() -> void:
	#leaderboard.show()
	#playButton.hide()

func _on_leaderboard_pressed() -> void:
	leaderboard.show()
	playButton.hide()

#func _on_close_button_released() -> void:
	#leaderboard.hide()
	#playButton.show()

func _on_close_button_pressed() -> void:
	leaderboard.hide()
	playButton.show()

func _on_setting_pressed() -> void:
	$AudioSetting.show()

func _on_close_audio_setting_pressed() -> void:
	$AudioSetting.hide()
