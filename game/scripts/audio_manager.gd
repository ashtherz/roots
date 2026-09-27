extends Node

var master : int
var music : int
var sfx : int

@onready var music_player: AudioStreamPlayer2D = $MusicPlayer
@onready var sfx_player1: AudioStreamPlayer2D = $SFXPlayer1
@onready var sfx_player2: AudioStreamPlayer2D = $SFXPlayer2
@onready var sfx_player3: AudioStreamPlayer2D = $SFXPlayer3

func _ready():
	pass

func _on_play_sfx(sfx) -> void:
	var sfx_players = [sfx_player1, sfx_player2, sfx_player3];
	for sfx_player in sfx_players:
		if !sfx_player.playing:
			var random_pitch = randf_range(0.8, 1.2)
			sfx_player.pitch_scale = random_pitch
			sfx_player.stream = sfx
			sfx_player.play()
			return

func _on_reset_music() -> void:
	music_player.stop()

func _on_play_music(music) -> void:
	music_player.stream = music
	music_player.play()
