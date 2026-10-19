extends Control

@export var isProcessOff: bool

@onready var coin_label = $CanvasLayer/NavBar/Coin/Coin
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	display_coin()

func display_coin():
	if GameManager.coin_global and coin_label != null:
		coin_label.text = str(GameManager.coin_global)

func _on_setting_pressed() -> void:
	$CanvasLayer/PausePanel.show()
	get_tree().paused = true
#Resume
func _on_resume_pressed() -> void:
	$CanvasLayer/PausePanel.hide()
	get_tree().paused = false
#Restart
func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
#Audio Setting
func _on_setting_button_pressed() -> void:
	$CanvasLayer/AudioSetting.show()
func _on_close_audio_setting_pressed() -> void:
	$CanvasLayer/AudioSetting.hide()
#Back to Home Screen
func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Screen Prefab/Home Screen.tscn")
