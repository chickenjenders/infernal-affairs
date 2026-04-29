extends Node

var num_sfx_players = 8
var sfx_players = []
var music_player: AudioStreamPlayer
var music_should_loop := false
var half_volume_music_paths = {
	"res://assets/sounds/bgmusic.wav": true,
	"res://assets/sounds/miserymanager.wav": true,
}

var click_sound = preload("res://assets/sounds/click.ogg")
var task_drop_sound = preload("res://assets/sounds/task.ogg")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	music_player.finished.connect(_on_music_finished)
	add_child(music_player)
	
	for i in range(num_sfx_players):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		sfx_players.append(p)
		
	# Connect to all existing buttons in the tree currently
	_connect_buttons(get_tree().root)
	
	# Automatically listen for new nodes to attach button click sounds
	get_tree().node_added.connect(_on_node_added)

func _connect_buttons(node: Node):
	if node is BaseButton:
		_on_node_added(node)
	for child in node.get_children():
		_connect_buttons(child)

func _on_node_added(node: Node):
	if node is BaseButton:
		# Connect to button down or pressed. button_down is usually more responsive
		if not node.is_connected("button_down", _play_click_sound):
			node.connect("button_down", _play_click_sound)

func _play_click_sound():
	play_sfx(click_sound)

func play_task_drop_sound():
	play_sfx(task_drop_sound)

func play_music(stream: AudioStream, _crossfade: float = 0.0):
	if music_player.stream == stream and music_player.playing:
		return
	music_should_loop = true
	music_player.stream = stream
	music_player.volume_db = -6.0 if stream and half_volume_music_paths.has(stream.resource_path) else 0.0
	music_player.play()

func stop_music():
	music_should_loop = false
	music_player.stop()

func _on_music_finished():
	if music_should_loop and music_player.stream:
		music_player.play(0.0)

func play_sfx(stream: AudioStream):
	if not stream:
		return
	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.play()
			return
	sfx_players[0].stream = stream
	sfx_players[0].play()
