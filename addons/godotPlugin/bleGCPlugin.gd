@tool
extends EditorPlugin

const AUTOLOAD_NAME = "SocketsConnect"

func _enable_plugin() -> void:
	print("Plugin Enabled")
	add_autoload_singleton(AUTOLOAD_NAME,"res://addons/godotPlugin/SocketsConnect.gd")
	


func _disable_plugin() -> void:
	# Remove autoloads here.
	remove_autoload_singleton(AUTOLOAD_NAME)


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
