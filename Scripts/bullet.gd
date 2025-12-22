extends CharacterBody3D

@export var speed := 50.0

func _physics_process(delta):
	var direction = -transform.basis.z
	var collision = move_and_collide(direction * speed * delta)

	if collision:
		var hit = collision.get_collider()
		if hit and hit.has_method("hit"):
			hit.hit()
		queue_free()
