@tool
extends Node

var websocket_url = "ws://localhost:9999"
var socket := WebSocketPeer.new()
var fileSent := false

var _stepping = false
var _pitch = 0.0
var _roll = 0.0
var _buttons = {}
signal pause_received
signal screenshot_received
signal photo_ready(jpeg_base64: String, has_gps: bool)
signal gpx_ready(gpx_xml: String)

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
			handle_message(socket.get_packet().get_string_from_ascii())
			#print("Recv. >", socket.get_packet().get_string_from_ascii(),"<")

#Send file function, usually used to send a layout to the server which will be passed to the phone
func sendfile(filename: String) -> void:
	var json_text = FileAccess.get_file_as_string(filename)
	socket.send_text(json_text)

#Indicates to the server that your game will be taking control of user inputs. Disables Xbox Controller Emulation
func take_control() -> void:
	while socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		await get_tree().create_timer(0.1).timeout
	var msg = {
		"type": "control",
		"command": "DISABLE_EMULATION"
	}
	socket.send_text(JSON.stringify(msg))

"""
If you wish to utilize the server's gpx trail generation but 
utilize your own screenshot system - you can use this function to send a photo to
tag it's EXIF with the current time and coordinates\
"""
func send_photo_(png_base64: String) -> void:
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		push_warning("Socket not open — cannot send photo")
		return
	var msg = JSON.stringify({"type": "photo_upload", "data": png_base64})
	socket.send_text(msg)

func start_gpx_trail(lat: float, lon:float) -> void:
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	var msg = JSON.stringify({"type": "gpx_start", "lat": lat, "lon": lon})
	socket.send_text(msg)
	
func send_gpx_point(lat: float, lon: float) -> void:
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	var msg = JSON.stringify({"type": "gpx_point", "lat": lat, "lon": lon})
	socket.send_text(msg)	

func stop_gpx_trail() -> void:
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	socket.send_text(JSON.stringify({"type": "gpx_stop"}))

func release_gpx_trail() -> void:
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	socket.send_text(JSON.stringify({"type": "gpx_release"}))

func release_control() -> void:
	var msg = {
		"type": "control",
		"command": "RELEASE_EMULATION"
	}
	socket.send_text(JSON.stringify(msg))

func handle_message(data: String ) -> void:
	var json = JSON.new()
	var err = json.parse(data)
	if err != OK:
		print("JSON parse error")
		return
	
	var payload = json.get_data()
	if typeof(payload) != TYPE_DICTIONARY:
		print("Unexpected Structure")
		return
	
	if not payload.has("type"):
		handle_input(payload)
		return 
		
	var msg_type = payload.get("type", "")
	if msg_type == "photo_response":
		emit_signal("photo_ready", payload["data"], payload.get("has_gps", false))
		return
	elif msg_type == "gpx_response":
		emit_signal("gpx_ready", payload["gpx_xml"])
		return
	elif msg_type == "pause":
		pause_received.emit()
	elif msg_type == "screenshot":
		screenshot_received.emit()
		
func handle_input(payload: Dictionary) -> void:
	if payload.has("stepping"):
		_stepping = payload["stepping"]
		
	if payload.has("pitch"):
		_pitch = payload["pitch"]
		
	if payload.has("roll"):
		_roll = payload["roll"]
		
	if payload.has("buttons") and typeof(payload["buttons"]) == TYPE_ARRAY:
		for button in payload["buttons"]:
			_buttons[button["name"]] = button["pressed"]
			
		
func getCurrentPitch() -> float:
	return _pitch
	
func getCurrentRoll() -> float:
	return _roll
	
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
