class_name Textbox extends PanelContainer

signal reached_end_of_line()
signal finished()

@export var instant: bool = false
@export var show_window: bool = true
@export var handle_input: bool = true
@export var pause_tree: bool = false
@export var use_sound: bool = true

var lines: Array = []
var speaker_name: String = ""
var current_position: Vector2 = Vector2.ZERO

@onready var dialogue: Label = $MarginContainer/ScrollContainer/VBoxContainer/Dialogue
@onready var scroll_container: ScrollContainer = $MarginContainer/ScrollContainer
@onready var typewriter: Timer = $Typewriter
@onready var typing: AudioStreamPlayer = $Typing

func _enter_tree() -> void:
	Globals.textbox = self

func _ready() -> void:
	#if Globals.player:
		#Globals.player.moved.connect(_on_player_moved)
		
	stop()
	self_modulate.a = 1.0 if show_window else 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if dialogue.visible_characters == -1:
			advance()
		else:
			# Skip typewriter effect and show all of current line.
			typewriter.stop()
			dialogue.visible_characters = -1
			reached_end_of_line.emit()
	elif event.is_action_pressed("ui_cancel"):
		stop()
	else:
		return
		
	get_viewport().set_input_as_handled()

func is_active() -> bool:
	return !dialogue.text.is_empty()
			
func start(speaker: String, text: Array, pos: Vector2 = position) -> void:
	if lines:
		return
		
	#print_debug(text)
	
	if !text:
		stop()
		return
		
	speaker_name = speaker
	position = pos
	#position = pos.clamp(Vector2.ZERO, Globals.GAME_SIZE - size)
	
	if pause_tree:
		get_tree().paused = true
	
	lines = text.duplicate()
	set_process_unhandled_input(handle_input)
	show()
	advance()

func stop() -> void:
	hide()
	lines.clear()
	dialogue.text = ""
	dialogue.visible_characters = -1
	typewriter.stop()
	set_process_unhandled_input(false)
	
	if pause_tree:
		await(get_tree().process_frame)
		await(get_tree().process_frame)
		get_tree().paused = false
		
	finished.emit()

func add(text: String) -> void:
	dialogue.text += "\n" + text
	if !instant:
		typewriter.start()
	await(get_tree().process_frame)
	scroll_container.set_deferred("scroll_vertical", 99999)

func advance() -> void:
	if lines:
		if instant:
			dialogue.visible_characters = -1
		else:
			dialogue.visible_characters = 0
			typewriter.start()
		
		dialogue.text = lines.pop_front()
	else:
		stop()

func wait(time: float) -> void:
	await(get_tree().create_timer(time).timeout)

func _on_typewriter_timeout() -> void:
	dialogue.visible_characters += 1
	
	if use_sound:
		typing.play()
	
	if is_equal_approx(dialogue.visible_ratio, 1.0):
		dialogue.visible_characters = -1
		typewriter.stop()
		reached_end_of_line.emit()	

func _on_player_moved(_pos: Vector2) -> void:
	stop()
