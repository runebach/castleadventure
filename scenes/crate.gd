extends RigidBody3D



func is_grabbed() -> void:
	self.gravity_scale = 0
	self.set_collision_layer_value(1, false)
	alternate_lock()

func is_released() -> void:
	self.gravity_scale = 1
	self.set_collision_layer_value(1, true)
	alternate_lock()

func alternate_lock() -> void:
	self.axis_lock_linear_x = !self.axis_lock_linear_x
	self.axis_lock_linear_z = !self.axis_lock_linear_z
	self.lock_rotation = !self.lock_rotation
