extends Node

const SAVE_PATH := "user://audio_settings.cfg"

@export var master_volume: float = 1.0
@export var music_volume: float = 1.0
@export var sfx_volume: float = 1.0    

func _ready():
	update_volumes()
	load_setting()

func _process(delta: float) -> void:
	pass

func update_volumes():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))

func set_master_volume(value: float):
	master_volume = value
	update_volumes()

func set_music_volume(value: float):
	music_volume = value
	update_volumes()

func set_sfx_volume(value: float):
	sfx_volume = value
	update_volumes()

func linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -80.0  # Effectively mute
	return 20.0 * log(linear) / log(10)

func save():
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "master_volume", master_volume)
	config.save(SAVE_PATH)

func load_setting():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		master_volume = config.get_value("audio", "master_volume", 0.5)
		music_volume = config.get_value("audio", "music_volume", 0.5)
		sfx_volume = config.get_value("audio", "sfx_volume", 0.5)
	update_volumes()
