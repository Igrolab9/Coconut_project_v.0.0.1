extends Node

# Массив с путями к трекам
var tracks: Array[String] = [
	"res://Sounds/Music/Island Breeze.mp3",
	"res://Sounds/Music/Island Dash.mp3",
	"res://Sounds/Music/Island Rush.mp3",
	"res://Sounds/Music/Tropic Bounce.mp3",
	"res://Sounds/Music/Tropic Rush (1).mp3",
	"res://Sounds/Music/Island Breeze.mp3"  # Замените на реальный 6-й трек!
]

var current_track_index: int = 0
var fade_time: float = 0.3

# ⭐ Ссылка на плеер внутри самого MusicManager
var audio_player: AudioStreamPlayer 

func _ready() -> void:
	# Создаем AudioStreamPlayer прямо здесь!
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player) # Добавляем как дочерний узел
	
	# Настраиваем громкость (опционально)
	audio_player.volume_db = -10.0 
	
	_load_track_index()
	_play_current_track()

func _play_current_track() -> void:
	# Загружаем трек напрямую в наш плеер
	var stream = load(tracks[current_track_index])
	if stream:
		audio_player.stream = stream
		audio_player.play()
		print("🎵 Играет трек: ", tracks[current_track_index])

func next_track() -> void:
	current_track_index = (current_track_index + 1) % tracks.size()
	_save_track_index()
	_play_current_track()

func _save_track_index() -> void:
	var file = FileAccess.open("user://track_index.txt", FileAccess.WRITE)
	if file:
		file.store_line(str(current_track_index))

func _load_track_index() -> void:
	if FileAccess.file_exists("user://track_index.txt"):
		var file = FileAccess.open("user://track_index.txt", FileAccess.READ)
		if file:
			var index = file.get_line().to_int()
			# Защита от выхода за границы массива
			if index >= 0 and index < tracks.size():
				current_track_index = index
