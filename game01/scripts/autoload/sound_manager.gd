extends Node

# SoundManager.gd - Procedural & Ambient Audio Manager (Default: Muted)

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer

# Muted by default as requested by user
var sound_enabled: bool = false
var ambient_volume: float = 0.5

func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	ambient_player = AudioStreamPlayer.new()
	add_child(ambient_player)
	
	GameState.money_changed.connect(_on_money_changed)
	GameState.upgrade_purchased.connect(_on_upgrade_purchased)

func _on_money_changed(amount: float, change: float) -> void:
	if change > 50.0 and sound_enabled:
		play_coin_chime()

func _on_upgrade_purchased(_category: String, _level: int) -> void:
	if sound_enabled:
		play_purchase_sound()

func play_coin_chime() -> void:
	if not sound_enabled: return
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 22050
	gen.buffer_length = 0.15
	
	sfx_player.stream = gen
	sfx_player.volume_db = -6.0
	sfx_player.play()
	
	var playback = sfx_player.get_stream_playback()
	if playback:
		var phase = 0.0
		var freq = 880.0
		for i in range(1200):
			var sample = sin(phase * TAU) * 0.3
			playback.push_frame(Vector2(sample, sample))
			phase = fmod(phase + freq / gen.mix_rate, 1.0)

func play_purchase_sound() -> void:
	if not sound_enabled: return
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 22050
	gen.buffer_length = 0.2
	
	sfx_player.stream = gen
	sfx_player.volume_db = -4.0
	sfx_player.play()
	
	var playback = sfx_player.get_stream_playback()
	if playback:
		var phase = 0.0
		var freq = 523.25
		for i in range(1600):
			if i > 800: freq = 659.25
			var sample = sin(phase * TAU) * 0.4
			playback.push_frame(Vector2(sample, sample))
			phase = fmod(phase + freq / gen.mix_rate, 1.0)

func toggle_sound() -> bool:
	sound_enabled = !sound_enabled
	return sound_enabled
