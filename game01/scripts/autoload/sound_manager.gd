extends Node

# sound_manager.gd - Procedural Sound Effects & Audio Engine for Study Cafe Tycoon

var sound_enabled: bool = false
var audio_player: AudioStreamPlayer

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	process_mode = Node.PROCESS_MODE_ALWAYS

func toggle_sound() -> bool:
	sound_enabled = not sound_enabled
	if sound_enabled:
		play_chime_sfx()
	return sound_enabled

func play_click_sfx() -> void:
	if not sound_enabled: return
	play_synth_tone(800.0, 0.05, "sine")

func play_coin_sfx() -> void:
	if not sound_enabled: return
	play_synth_tone(1200.0, 0.08, "triangle")

func play_clean_sfx() -> void:
	if not sound_enabled: return
	play_synth_tone(400.0, 0.12, "noise")

func play_chime_sfx() -> void:
	if not sound_enabled: return
	play_synth_tone(950.0, 0.15, "sine")

func play_synth_tone(freq: float, duration: float, type: String = "sine") -> void:
	var sample_rate = 22050
	var num_samples = int(sample_rate * duration)
	var buffer = PackedByteArray()
	buffer.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / sample_rate
		var sample_val = 0.0
		var env = 1.0 - (float(i) / num_samples) # Linear decay
		
		if type == "sine":
			sample_val = sin(t * freq * TAU) * env
		elif type == "triangle":
			sample_val = (abs(fmod(t * freq * 4.0, 4.0) - 2.0) - 1.0) * env
		elif type == "noise":
			sample_val = (randf() * 2.0 - 1.0) * env
			
		var int_val = int(clamp(sample_val, -1.0, 1.0) * 32767.0)
		buffer.encode_s16(i * 2, int_val)
		
	var wav = AudioStreamWav.new()
	wav.format = AudioStreamWav.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = buffer
	
	audio_player.stream = wav
	audio_player.play()
