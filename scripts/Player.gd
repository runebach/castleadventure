extends CharacterBody3D

@export var inventory_data: InventoryData

# CONSTS
const TURN_SPEED: float = 0.0075

#EXPORTS
@export var jump_velocity: float = 4.5
@export var base_speed: float = 3
var speed_modifier: float = 1

#ONREADY
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var player = $"."
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var interact_ray = $Neck/Camera3D/InteractRay
@onready var grab_ray = $Neck/Camera3D/GrabRay
@onready var footsteps = $Footsteps
@onready var head_bob_animation = $AnimationPlayer



# Miscellanious variables
var can_grab_object: bool = false
var is_carrying_object: bool = false
var can_look_around: bool = true

var object_to_grab_name
var grabbed_object
var grabbed_object_parent

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
		velocity.x = direction.x * base_speed * speed_modifier
		velocity.z = direction.z * base_speed * speed_modifier
	else:
		velocity.x = move_toward(velocity.x, 0, base_speed * speed_modifier)
		velocity.z = move_toward(velocity.z, 0, base_speed * speed_modifier)
	move_and_slide()
	
	#Handle player movement animation
	if velocity != Vector3() and is_on_floor():
		head_bob_animation.play("head_bob")


#Handles mouse input
func _unhandled_input(event: InputEvent):
	#Only handle movement if mouse is 'captured'
	if(Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		if(event is InputEventMouseMotion and can_look_around):
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
	
	#if Input.is_action_just_pressed("grab"):
		#pass
	grab_and_release()

func interact() -> void:
	if interact_ray.is_colliding():
		print("interact")
		interact_ray.get_collider().player_interact()

func play_footstep_audio() -> void:
	footsteps.pitch_scale = randf_range(0.8, 1.2)
	footsteps.play()

func grab_raycast():
	#Check raycast collision
	if grab_ray.is_colliding():
		can_grab_object = true
		object_to_grab_name = grab_ray.get_collider().name
		
	else:
		can_grab_object = false
		object_to_grab_name = null

func grab_and_release():
	grab_raycast()
	
	if Input.is_action_just_pressed("grab"):
		
		if is_carrying_object == false:
			if can_grab_object :
				var root = get_tree().root
				grabbed_object = root.get_child(1).get_node("Map/Obstacles/" + str(object_to_grab_name))
				print(grabbed_object)
				grabbed_object_parent = grabbed_object.get_parent()
				grabbed_object.reparent(self)
				grabbed_object.is_grabbed()
				is_carrying_object = true
				can_look_around = false
				speed_modifier = 0.5
		else:
			grabbed_object.reparent(grabbed_object_parent)
			is_carrying_object = false
			grabbed_object.is_released()
			can_look_around = true
			speed_modifier = 1



