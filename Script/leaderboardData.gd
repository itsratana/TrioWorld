extends Node

var PF: PlayFabManager = PlayFabManager
var GM: GameManager = GameManager
# Called when the node enters the scene tree for the first time.
# Leaderboard handling
const LEADERBOARD_NAME = "TrioWorld_Leaderboard_score"
var leaderboard_names: Array = []
var leaderboard_scores: Array = []
var leaderboard_rank: Array = []
var own_rank: Array = []

@export var is_leaderboard_ready: bool = false
signal leaderboard_updated(names, scores)
signal leaderboard_ready

# Fetch leaderboard
func get_leaderboard():
	var request_body = {
		"StatisticName": LEADERBOARD_NAME,
		"StartPosition": 0,
		"MaxResultsCount": 10
	}

	get_own_rank()
	print("Fetching leaderboard data...")

	PF.client.post_dict_auth(
		request_body,
		"/Client/GetLeaderboard",
		PlayFab.AUTH_TYPE.SESSION_TICKET,
		Callable(self, "_on_get_leaderboard")
	)

func _on_get_leaderboard(response):
	if response.has("error"):
		print("Error fetching leaderboard:", response["error"])
	else:
		var leaderboard_data = response.get("data", {}).get("Leaderboard", [])
		leaderboard_names.clear()
		leaderboard_scores.clear()
		leaderboard_rank.clear()

		for entry in leaderboard_data:
			#leaderboard_names.append(entry.get("DisplayName", "Unknown Player"))
			#leaderboard_scores.append(entry.get("StatValue", 0))
			#leaderboard_rank.append(entry.get("Position", -1) + 1)
			var display_name = entry.get("DisplayName", "Unknown Player")
			var scoreConvert = entry.get("StatValue", 0)
			var score = -scoreConvert

			# Convert raw milliseconds score to formatted time
			var hours = score / 3600000
			var minutes = (int(score) % 3600000) / 60000
			var seconds = (int(score) % 60000) / 1000
			var milliseconds = (int(score) % 1000) / 10  # two-digit display

			var formatted = "%01dH %01dM %01dS %01dMS" % [hours, minutes, seconds, milliseconds]
			#var formatted = format_score_clean(score)
			# Append to your arrays
			leaderboard_names.append(display_name)
			leaderboard_scores.append(formatted)  # formatted time instead of raw
			leaderboard_rank.append(entry.get("Position", -1) + 1)

		print("Leaderboard data fetched successfully.")
		is_leaderboard_ready = true
		emit_signal("leaderboard_updated", leaderboard_names, leaderboard_scores)
		emit_signal("leaderboard_ready")

#func format_score_clean(score: int) -> String:
	#var hours = score / 3600000
	#var minutes = (score % 3600000) / 60000
	#var seconds = (score % 60000) / 1000
	#var milliseconds = (score % 1000) / 10
#
	#var parts := []
#
	#if hours > 0:
		#parts.append(str(hours))
		#parts.append(String(str(minutes)).pad_zeros(2))
		#parts.append(String(str(seconds)).pad_zeros(2))
		#parts.append(String(str(milliseconds)).pad_zeros(2))
	#elif minutes > 0:
		#parts.append(str(minutes))
		#parts.append(String(str(seconds)).pad_zeros(2))
		#parts.append(String(str(milliseconds)).pad_zeros(2))
	#elif seconds > 0:
		#parts.append(str(seconds))
		#parts.append(String(str(milliseconds)).pad_zeros(2))
	#else:
		#parts.append("0")
		#parts.append(String(str(milliseconds)).pad_zeros(2))
	#return ":".join(parts)

# Fetch player's own rank
func get_own_rank_info():
	return own_rank
	
func get_own_rank():
	var request_body = {
		"StatisticName": LEADERBOARD_NAME,
		"MaxResultsCount": 1
	}

	PF.client.post_dict_auth(
		request_body,
		"/Client/GetLeaderboardAroundPlayer",
		PlayFab.AUTH_TYPE.SESSION_TICKET,
		Callable(self, "_on_get_own_rank")
	)

var has_valid_rank: bool = false 

func _on_get_own_rank(response):
	if response.has("error"):
		print("Error fetching own rank:", response["error"])
	else:
		var player_data = response.get("data", {}).get("Leaderboard", [])
		if player_data.size() > 0:
			var player_entry = player_data[0]
			var score = player_entry.get("StatValue", 0)
			print(score)
			own_rank = [
				player_entry.get("Position", -1) + 1,
				player_entry.get("DisplayName", "You"),
				score
			]
			has_valid_rank = score < 0
		else:
			has_valid_rank = false

# Update leaderboard score
func update_leaderboard_score(score: int):
	var request_body = {
		"Statistics": [
			{
				"StatisticName": LEADERBOARD_NAME,
				"Value": score
			}
		]
	}

	print("Updating leaderboard score...")

	PF.client.post_dict_auth(
		request_body,
		"/Client/UpdatePlayerStatistics",
		PlayFab.AUTH_TYPE.SESSION_TICKET,
		Callable(self, "_on_update_leaderboard_score")
	)

func get_own_formatted_score() -> String:
	if own_rank.size() >= 3:
		var raw_score_convert = own_rank[2]
		var raw_score = -raw_score_convert
		var hours = raw_score / 3600000
		var minutes = (int(raw_score) % 3600000) / 60000
		var seconds = (int(raw_score) % 60000) / 1000
		var milliseconds = (int(raw_score) % 1000) / 10
		return "%01dH %01dM %01dS %01dMS" % [hours, minutes, seconds, milliseconds]
	else:
		return "00:00:00:00"

func _on_update_leaderboard_score(response):
	if response.has("error"):
		print("Error updating leaderboard:", response["error"])
	else:
		get_leaderboard()
		print("Leaderboard updated successfully.")
