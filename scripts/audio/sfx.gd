extends Node
## Procedural sound effects generated at runtime (no external assets).

const SAMPLE_RATE := 22050

var _players: Array[AudioStreamPlayer] = []
var _pool_index: int = 0
var _cache: Dictionary = {}


func _ready() -> void:
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)


func _next_player() -> AudioStreamPlayer:
	var p := _players[_pool_index]
	_pool_index = (_pool_index + 1) % _players.size()
	return p


func play(stream: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if stream == null:
		return
	var p := _next_player()
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = pitch
	p.play()


func play_tone(freq: float, duration: float, volume_db: float = -6.0, wave: int = 0) -> void:
	var key := "%s_%s_%s" % [freq, duration, wave]
	if not _cache.has(key):
		_cache[key] = _make_tone(freq, duration, wave)
	play(_cache[key], volume_db)


func _make_tone(freq: float, duration: float, wave: int) -> AudioStreamWAV:
	var count := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		var t := float(i) / SAMPLE_RATE
		var env := 1.0 - (float(i) / count)
		env = env * env
		var s := 0.0
		match wave:
			0:
				s = sin(TAU * freq * t)
			1:
				s = 1.0 if fmod(freq * t, 1.0) < 0.5 else -1.0
			2:
				s = randf_range(-1.0, 1.0)
			_:
				s = sin(TAU * freq * t)
		var v := int(clamp(s * env * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, v)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream
