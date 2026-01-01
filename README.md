To install, download the godotPlugin folder and add to your godot game. Then enable the plugin in godot settings. The plugin should autoload the script that handles connection to py server
To use inputs, connect to the signals using SocketsConnect.step_received.connect(handler) (button_pressed or tilt_received) and implement handler.
