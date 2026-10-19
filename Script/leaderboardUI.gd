extends Control

var LD: LeaderboardData = LeaderboardData
var GM: GameManager = GameManager

@onready var leaderboard_name_labels := [
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect1/Username",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect2/Username",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect3/Username",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect4/Username",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect5/Username",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect6/Username",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect7/Username",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect8/Username",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect9/Username",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect10/Username"
]

@onready var leaderboard_score_labels := [
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect1/Score",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect2/Score",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect3/Score",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect4/Score",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect5/Score",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect6/Score",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect7/Score",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect8/Score",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect9/Score",
	$"Level 1 Leaderboard/ScrollContainer/VBoxContainer/TextureRect10/Score"
]

@onready var highestScore = $"../HomeScreen/Level 1 Panel/Highscore2"
@onready var userName = $OwnScore/Username
@onready var userScore = $OwnScore/Score
@onready var userRank = $OwnScore/Rank
var formatted_score

var dummy_names := ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Ghost", "Hunter", "Iceman", "Joker"]
var rng := RandomNumberGenerator.new()

func _ready():
	LD.connect("leaderboard_updated", Callable(self, "update_leaderboard_ui"))
	
	if LD.is_leaderboard_ready:
		update_leaderboard_ui(LD.leaderboard_names, LD.leaderboard_scores)
	else:
		print("Wait for updating leaderboard data")

func update_leaderboard_ui(names:Array, scores:Array) -> void:
	var has_real_data = names.size() > 0
	rng.randomize()
	
	for i in range(leaderboard_name_labels.size()):
		if has_real_data and i < names.size():
			leaderboard_name_labels[i].text = names[i]
			leaderboard_score_labels[i].text = scores[i]
		else:
			var name = dummy_names[rng.randi_range(0, dummy_names.size() - 1)]
			#var time = "%02d:%02d:%02d" % [rng.randi_range(0, 59), rng.randi_range(0, 59), rng.randi_range(0, 59)]
			
			leaderboard_name_labels[i].text = name
			#leaderboard_score_labels[i].text = ""
	if has_real_data and scores.size() > 0:
		highestScore.text = LD.get_own_formatted_score()
	else:
		highestScore.text = "0H 0M 0S 0MS"
		
	var own_info = LD.get_own_rank_info()
	if LD.has_valid_rank:
		userName.text = own_info[1]  # DisplayName
		userScore.text = LD.get_own_formatted_score()  # Already formatted
		userRank.text = "#" + str(own_info[0])  # Rank (1-based)
		
		if own_info[0] == 1:
			$"OwnScore/1".show()
		elif own_info[0] == 2:
			$"OwnScore/2".show()
		elif own_info[0] == 3:
			$"OwnScore/3".show()
		else:
			$"OwnScore/1".hide()
			$"OwnScore/2".hide()
			$"OwnScore/3".hide()
	else:
		userName.text = "You"
		userScore.text = "0H 0M 0S 0MS"
		userRank.text = "-"
