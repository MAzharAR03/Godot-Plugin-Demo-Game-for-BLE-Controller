@tool
extends Node

var websocket_url = "ws://localhost:9999"
var socket := WebSocketPeer.new()
var fileSent := false

var _stepping = false
var _pitch = 0.0
var _buttons = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if socket.connect_to_url(websocket_url) != OK:
		print("Could not connect.")
		set_process(false)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	socket.poll()
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			handle_input(socket.get_packet().get_string_from_ascii())
			#print("Recv. >", socket.get_packet().get_string_from_ascii(),"<")

func sendfile(filename: String) -> void:
	var json_text = FileAccess.get_file_as_string(filename)
	socket.send_text(json_text)
	
func handle_input(data: String) -> void:
	var json = JSON.new()
	var err = json.parse(data)
	if err != OK:
		print("JSON parse error")
		return
	
	var payload = json.get_data()
	if typeof(payload) != TYPE_DICTIONARY:
		print("Unexpected Structure")
		return
		
	if payload.has("stepping"):
		_stepping = payload["stepping"]
		
	if payload.has("pitch"):
		_pitch = payload["pitch"]
		
	if payload.has("buttons") and typeof(payload["buttons"]) == TYPE_ARRAY:
		for button in payload["buttons"]:
			_buttons[button["name"]] = button["pressed"]
			
		
func getCurrentPitch() -> float:
	return _pitch
	
func isStepping() -> bool:
	return _stepping

func isButtonPressed(button_name: String) -> bool:
	return _buttons.get(button_name, false)

func getButtons() -> Dictionary:
	return _buttons.duplicate()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F5:  # Press F5 to send file
			sendfile("res://addons/godotPlugin/Test.json")
