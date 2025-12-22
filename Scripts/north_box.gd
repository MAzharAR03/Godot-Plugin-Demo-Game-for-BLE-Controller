extends CSGBox3D

@export var HIT_COLOR := Color.RED
@export var REVERT_TIME := 2.0

var original_material: Material
var timer: Timer

func _ready():
	original_material = material
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = REVERT_TIME
	timer.timeout.connect(_on_revert_timeout)
	add_child(timer)

func hit():
	var mat := StandardMaterial3D.new()
	mat.albedo_color = HIT_COLOR
	material = mat
	timer.start()

func _on_revert_timeout():
	material = original_material
