extends Area2D

@export var coin_reward: int = 300
var activated := false

@onready var player:CharacterBody2D = $"../Player"
@onready var chestSprite = $AnimatedSprite2D

var has_update_coin := false

func _ready():
	connect("body_entered", Callable(self, "_on_trigger_body_entered"))
	#chestSprite.play("ChestIdle")

func _process(delta: float) -> void:
	#if player.toUpdateData:
		#if not has_update_coin:
			#GameManager.coin_global += player.coins
			#GameManager.update_player_stats_to_playfab(true)
			#has_update_coin = true
		#return
	#$"../../Control/CanvasLayer/NavBar/Coin/Coin".text = "%d" % GameManager.coin_global
	pass

func _on_trigger_body_entered(body):
	if activated:
		return
	if body.is_in_group("player"):
		AudioManager.play_sfx("ChestCoin")
		$"../../Control/CanvasLayer/AnimationPlayer".play("coinx300")
		chestSprite.play("ChestOpen")
		activated = true
		# Set the player reference
		player = body
		$CollisionShape2D.disabled = true
		# Update the player's coins in CoinTrigger
		await get_tree().create_timer(3).timeout
		GameManager.coin_global += coin_reward
		GameManager.update_coin_to_playfab()
		# Optionally: Remove the coin trigger after collection
