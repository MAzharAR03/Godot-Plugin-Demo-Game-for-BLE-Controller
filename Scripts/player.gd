extends CharacterBody3D

@onready var head: Node3D = $head
@onready var camera_3d: Camera3D = $head/Camera3D
var bullet = load("res://Scenes/bullet.tscn")
@onready var pos: Node3D = $head/Camera3D/gun/pos


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CAMERA_SENS = 0.2
const STEP_DURATION = 0.5
const THRESHOLD = 0.05

var steppingTimer = 0.0

func _ready() -> void:
	SocketsConnect.take_control()

func _exit_tree() -> void:
	SocketsConnect.release_control()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if SocketsConnect.isStepping():
		var forward_direction = -camera_3d.global_transform.basis.z
		forward_direction.y = 0
		forward_direction = forward_direction.normalized()
		velocity.x = forward_direction.x * SPEED
		velocity.z = forward_direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 10)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta * 10)
	
	if(abs(SocketsConnect.getCurrentPitch())>THRESHOLD):
		rotate_y(SocketsConnect.getCurrentPitch() * CAMERA_SENS)
	
	if (abs(SocketsConnect.getCurrentRoll())>THRESHOLD):
		head.rotate_x(-SocketsConnect.getCurrentRoll() * CAMERA_SENS)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
	if SocketsConnect.isButtonPressed("X"):
		var instance=bullet.instantiate()
		instance.position = pos.global_position
		instance.transform.basis = pos.global_transform.basis
		get_parent().add_child(instance)
		print("Fire")
	move_and_slide()

	
	
