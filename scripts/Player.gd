extends CharacterBody3D

@export var inventory_data: InventoryData

# CONSTS
const SPEED = 3
const TURN_SPEED = 0.0075

#EXPORTS
@export var jump_velocity = 4.5

#ONREADY
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var interact_ray = $Neck/Camera3D/InteractRay
@onready var footsteps = $Footsteps
@onready var head_bob_animation = $AnimationPlayer



func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	if velocity != Vector3() and is_on_floor():
		head_bob_animation.play("head_bob")

#Handles mouse input
func _unhandled_input(event: InputEvent):
	#Only handle movement if mouse is 'captured'
	if(Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		if(event is InputEventMouseMotion):
			neck.rotate_y(-event.relative.x * TURN_SPEED)
			camera.rotate_x(-event.relative.y * TURN_SPEED)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
			
	#If escape is activated, we make the mouse visible (for menus etc.)
	if(event.is_action_pressed("escape")):
		get_tree().quit()
	

	
	if Input.is_action_just_pressed("inventory"):
		signal_bus.toggle_inventory.emit()
	
	if Input.is_action_just_pressed("interact"):
		interact()

func interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()

func play_footstep_audio() -> void:
	footsteps.pitch_scale = randf_range(0.8, 1.2)
	footsteps.play()

