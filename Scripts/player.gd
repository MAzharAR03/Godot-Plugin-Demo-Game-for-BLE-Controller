extends CharacterBody3D

@onready var head: Node3D = $head
@onready var camera_3d: Camera3D = $head/Camera3D
var bullet = load("res://Scenes/bullet.tscn")
@onready var pos: Node3D = $head/Camera3D/gun/pos


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CAMERA_SENS = 0.4
const STEP_DURATION = 0.5

var steppingTimer = 0.0

func _ready() -> void:
	SocketsConnect.step_received.connect(handle_step)
	SocketsConnect.button_pressed.connect(handle_button)
	SocketsConnect.tilt_received.connect(handle_tilt)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if SocketsConnect.stepping:
		steppingTimer -= delta
		var forward_direction = -camera_3d.global_transform.basis.z
		forward_direction.y = 0
		forward_direction = forward_direction.normalized()
		velocity.x = forward_direction.x * SPEED
		velocity.z = forward_direction.z * SPEED
		if steppingTimer <= 0.0:
			SocketsConnect.setStepping(false)
			velocity.x = 0
			velocity.z = 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 10)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta * 10)
		
	move_and_slide()


func handle_tilt() -> void:
	rotate_y(SocketsConnect.getCurrentTilt() * CAMERA_SENS)

func handle_step() -> void:
	steppingTimer = STEP_DURATION
	print("Step!")

func handle_button() -> void:
	var instance=bullet.instantiate()
	instance.position = pos.global_position
	instance.transform.basis = pos.global_transform.basis
	get_parent().add_child(instance)
	print("Fire")
	
	
