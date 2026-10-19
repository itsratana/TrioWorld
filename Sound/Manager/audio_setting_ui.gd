extends Control

@onready var master_slider = $MasterVolumeSlider
@onready var music_slider = $MusicVolumeSlider
@onready var sfx_slider = $SFXVolumeSlider

func _ready() -> void:
	master_slider.value = VolumnManager.master_volume * 100
	music_slider.value = VolumnManager.music_volume * 100
	sfx_slider.value = VolumnManager.sfx_volume * 100

func _on_music_volumn_slider_value_changed(value: float) -> void:
	var linear_value = value / 100.0 
	VolumnManager.set_music_volume(linear_value)
	VolumnManager.save()
	$Music.text = "%d%%" % value

func _on_sfx_volumn_slider_value_changed(value: float) -> void:
	var linear_value = value / 100.0
	VolumnManager.set_sfx_volume(linear_value)
	VolumnManager.save()
	$SFX.text = "%d%%" % value

func _on_master_volume_slider_value_changed(value: float) -> void:
	var linear_value = value / 100.0
	VolumnManager.set_master_volume(linear_value)
	VolumnManager.save()
	$Master.text = "%d%%" % value
