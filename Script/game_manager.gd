extends Node

var PF: PlayFabManager = PlayFabManager
var LD: LeaderboardData = LeaderboardData

var UserID:String
var UserName:String
var UserPlayFabData

var IsLoading: bool = true

var highscore_global
var coin_global: int
var gems_global: int

var is_logged_in: bool = false
#var is_leaderboard_ready: bool = false
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
#var today_date
func _ready():
	get_telegram_data()
	print(PF)
	#highscore_global = LD.get_own_formatted_score()

# Fetch Telegram user data
func get_telegram_data():
	var js_code ="Tg.getUser();"
	var dataString = JavaScriptBridge.eval(js_code, true)
	if dataString == null:
		dataString = JSON.stringify({
			"id": 111213,
			"first_name": "",
			"last_name": "Admin",
			"username": ""
		})
	
	var result = JSON.parse_string(dataString)
	if result:
		request_completed(result)
	else:
		print("Error: Invalid JSON data from Telegram.")

func request_completed(body):
	if body:
		UserID = str(body.get("id", 0))
		UserName = str(body.get("username", ""))
		login_with_custom_id()

# PlayFab login
func login_with_custom_id():
	var reqParams = GetPlayerCombinedInfoRequestParams.new()
	reqParams.GetUserData = true
	reqParams.GetUserAccountInfo = true
  
  # Ensure event connection before logging in
	PF.client.connect("logged_in", Callable(self, "_on_login"))
	PF.client.login_with_custom_id(UserID, true, reqParams)

func _on_login(res: LoginResult):
	UserPlayFabData = res.InfoResultPayload.to_dict()
	print("Log in")
	# Login successful, get leaderboard
	LeaderboardData.get_leaderboard()
	is_logged_in = true
	
	if "Gem" not in UserPlayFabData.get("UserData", {}):
		update_player_gem_for_new_account()
	else :
		var gem_data = UserPlayFabData.get("UserData", {}).get("Gem", {}).get("Value", "")
		gems_global = JSON.parse_string(gem_data).get("Gem", 0)

  # Check for user data
	if "TrioWorld" in UserPlayFabData.get("UserData", {}):
		update_display_name()
		get_data_to_game(UserPlayFabData)
		#update_coin_to_playfab()
	else:
		update_display_name()
		update_player_stats_for_new_account()

#Update PlayFab display name
func update_display_name():
	var dict = {"DisplayName": UserName}
	PF.client.post_dict_auth(
	dict,
	"/Client/UpdateUserTitleDisplayName",
	PlayFab.AUTH_TYPE.SESSION_TICKET,
	Callable(self, "_on_display_name_updated")
		)

func _on_display_name_updated(result):
	print("Display name updated successfully.")

# Fetch player data from PlayFab
func get_data_to_game(response):
	var trio_world = response.get("UserData", {}).get("TrioWorld", {}).get("Value", "")
	if trio_world != "":
		var parsed = JSON.parse_string(trio_world)
		if parsed:
			highscore_global = parsed.get("Highscore", 0)
			coin_global = parsed.get("Coin", 0)  # <-- this sets your coin_global at login
			print("Loaded from PlayFab:", coin_global)

 #Initialize new player data
func update_player_stats_for_new_account():
	IsLoading = true
	var request_body = {
		"Data": {
			"TrioWorld": JSON.stringify({
				"Highscore": 0,
				"Coin": 0,
			})
		}
	}
	
	PF.client.post_dict_auth(
		request_body,
			"/Client/UpdateUserData",
		PlayFab.AUTH_TYPE.SESSION_TICKET,
		Callable(self, "_on_update_player")
		)

func update_player_gem_for_new_account():
	gems_global = 0
	var request_body = {
		"Data": {
			"Gem": JSON.stringify({
				"Gem": 0,
			})
		}
	}
	PF.client.post_dict_auth(
		request_body,
		"/Client/UpdateUserData",
		PlayFab.AUTH_TYPE.SESSION_TICKET,
		Callable(self, "_on_update_player")
	)

var noNeedIsloading: bool
# Update player stats to PlayFab

func update_player_stats_to_playfab(status: bool):
	noNeedIsloading = status
	if noNeedIsloading:
		noNeedIsloading = true
		LD.update_leaderboard_score(highscore_global)

func update_coin_to_playfab():
	var request_body = {
		"Data": {
			"TrioWorld": JSON.stringify({
				"Highscore": LD.own_rank[2],
				"Coin": coin_global,
			})
		}
	}
	PF.client.post_dict_auth(
		request_body,
		"/Client/UpdateUserData",
		PlayFab.AUTH_TYPE.SESSION_TICKET,
		Callable(self, "_on_update_player")
	)
