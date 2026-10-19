extends Node

var active_music_stream: AudioStreamPlayer

@export_group("Main")
@export var music:Node
@export var sfx:Node

func play_music(audio_name:String, from_position:float = 0.0, skip_restart:bool = false):
	
	if skip_restart and active_music_stream and active_music_stream.name == audio_name:
		return
	
	if active_music_stream and active_music_stream.playing:
		active_music_stream.stop()
	
	active_music_stream = music.get_node(audio_name)
	active_music_stream.play(from_position)

func play_sfx(audio_name: String):
	var sfx_player = sfx.get_node(audio_name)
	sfx_player.play()

func stop_sfx(audio_name: String):
	var sfx_player = sfx.get_node(audio_name)
	sfx_player.stop()
