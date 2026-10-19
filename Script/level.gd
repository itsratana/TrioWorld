extends Node

@export var start_y: float = 0  # Starting Y position
@export var current_height = 0  # Current height above start
@export var max_height:float  # Maximum height reached

@onready var tutorialScreen = $Control/CanvasLayer/Tutorial
@export var tutorialScreenOn: bool

@onready var touchScreen = $Control/CanvasLayer/TouchControl
@onready var player = $Player
@onready var timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_music("InGame",0.0 ,true)
	start_y = player.global_position.y
	tutorialScreen.show()
	tutorialScreenOn = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if InGameUiManager.isProcessOff or tutorialScreenOn:
		#player.set_process(false)
		#player.set_physics_process(false)
		timer.set_process(false)
		timer.set_physics_process(false)
		player.input_enabled = false
		touchScreen.hide()
	elif !InGameUiManager.isProcessOff and !tutorialScreenOn:
		#player.set_process(true)
		#player.set_physics_process(true)
		timer.set_process(true)
		timer.set_physics_process(true)
		#player.input_enabled = true
		touchScreen.show()
	
	current_height = (start_y - player.global_position.y)/100
	
	if current_height > max_height:
		max_height = (start_y - player.global_position.y)/100

func _on_player_change_camera_pos(player_pos):
	$Camera2D.position.y = player_pos


func _on_touch_screen_button_pressed() -> void:
	tutorialScreen.hide()
	tutorialScreenOn = false
	$Control/CanvasLayer/NavBar.show()
	player.input_enabled = true
	#player.set_process(true)
	#player.set_physics_process(true)

func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://Screen Prefab/Home Screen.tscn")
	InGameUiManager.isProcessOff = false

func _on_replay_pressed() -> void:
	get_tree().reload_current_scene()
	InGameUiManager.isProcessOff = false
