extends Control

var LD: LeaderboardData = LeaderboardData
var GM: GameManager = GameManager

@onready var progress_bar = $TextureProgressBar   # your progress bar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var progress := 0.0

func _process(delta):
	var targets = [GM.is_logged_in, LD.is_leaderboard_ready]
	var loaded_count = targets.count(true)
	var total = targets.size()

	# Smoothly fill the bar toward the current load state
	var target_progress = float(loaded_count) / total * 100.0
	progress = lerp(progress, target_progress, delta * 5)
	progress_bar.value = progress

	if loaded_count == total and progress >= 99.9:
		start_game()

func start_game():
	set_process(false)  # prevent multiple triggers
	animation_player.play("fade")
	await get_tree().create_timer(0.5).timeout
	self.hide()
	#get_tree().change_scene_to_file("res://Screen Prefab/Home Screen.tscn")
