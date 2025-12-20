extends Node

var websocket_url = "ws://localhost:9999"
var socket := WebSocketPeer.new()

var current_tilt := 0.0
var stepping := false
var buttonPress := false #make it array of buttons and dynamically create depending on layout?

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
			print("Recv. >", socket.get_packet().get_string_from_ascii(),"<")
	
func handle_input(data: String) -> void:
	var split_string = data.split(":")
	if(split_string[0] == "Tilt"):
		current_tilt = split_string[1].to_float()
	elif(split_string[0] == "Step"):
		stepping = true
	elif(split_string[0] == "Button"):
		buttonPress = true
	else:
		print("Unknown input")
		
func getCurrentTilt() -> float:
	return current_tilt

func getStepping() -> bool:
	return stepping
	
func setStepping(data: bool) -> void:
	stepping = data
	
func getButtonPress() -> bool:
	return buttonPress

func setButtonPress(data: bool) -> void:
	buttonPress = data
