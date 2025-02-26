extends RigidBody3D



func is_grabbed() -> void:
	self.gravity_scale = 0
	self.set_collision_layer_value(1, false)
	self.lock_rotation = true

func is_released() -> void:
	self.gravity_scale = 1
	self.set_collision_layer_value(1, true)
	self.lock_rotation = false
