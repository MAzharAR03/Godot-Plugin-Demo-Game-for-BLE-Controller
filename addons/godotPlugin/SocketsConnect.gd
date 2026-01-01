@tool
extends Node

var websocket_url = "ws://localhost:9999"
var socket := WebSocketPeer.new()
var fileSent := false

signal step_received
signal button_pressed
signal tilt_received

var current_tilt := 0.0
var stepping = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if socket.connect_to_url(websocket_url) != OK:
		print("Could not connect.")
		set_process(false)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	socket.poll()
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		if(!fileSent):
			sendfile("res://addons/godotPlugin/Test.json")
			fileSent = true
		while socket.get_available_packet_count():
			handle_input(socket.get_packet().get_string_from_ascii())
			#print("Recv. >", socket.get_packet().get_string_from_ascii(),"<")

func sendfile(filename: String) -> void:
	var json_text = FileAccess.get_file_as_string(filename)
	socket.send_text(json_text)
	
func handle_input(data: String) -> void:
	var split_string = data.split(":")
	if(split_string[0] == "Tilt"):
		current_tilt = split_string[1].to_float()
		tilt_received.emit()
	elif(split_string[0] == "Step"):
		stepping = true
		step_received.emit()
	elif(split_string[0] == "Button"):
		button_pressed.emit()
	else:
		print("Unknown input")
		
func getCurrentTilt() -> float:
	return current_tilt
	
func isStepping() -> bool:
	return stepping

func setStepping(value: bool) -> void:
	stepping = value
	
