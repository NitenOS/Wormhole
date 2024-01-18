extends CharacterBody3D

@onready var animated_sprite_2d = $CanvasLayer/GunBase/AnimatedSprite2D
@onready var ray_cast_3d = $RayCast3D
@onready var shoot_sound = $ShootSound

const SPEED : float = 0.05
const SENS : float = 3
const MAX_SPEED : int = 10

var can_shoot : bool = true
var dead : bool = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animated_sprite_2d.animation_finished.connect(shoot_anim_done)
	$CanvasLayer/DeathScreen/Panel/Button.button_up.connect(restart)
	pass
	
func _input(event):
	if dead:
		return
	if event is InputEventMouseMotion:
		pass
	
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
		pass
	if Input.is_action_just_pressed("restart"):
		restart()
		pass
		
	if dead:
		return
	if Input.is_action_just_pressed("shoot"):
		shoot()
		pass
	arrow_direction()
		
	
	pass

func _physics_process(delta):
	if dead:
		return
	var input_dir = Input.get_axis("move_forwards", "move_backwards")
	var input_stafe = Input.get_axis("strafe_left", "strafe_right") 
	var direction = (transform.basis * Vector3(0, 0, input_dir)).normalized()
	
	if Input.is_action_just_pressed("strafe_left") or Input.is_action_just_pressed("strafe_right") :
		direction += (transform.basis * Vector3(input_stafe, 0, 0)).normalized() * 50
		
	if direction and velocity.length() < MAX_SPEED:
		velocity.x += direction.x * SPEED
		velocity.z += direction.z * SPEED
	
	if velocity.length() > MAX_SPEED:
		velocity.x = move_toward(velocity.x, 0, 0.1)
		velocity.z = move_toward(velocity.z, 0, 0.1)
		
	print(velocity.x)
	
	var input_orientation = Input.get_axis("watch_left", "watch_right")
	rotation_degrees.y -= input_orientation * SENS
	
	move_and_slide()
	pass

func restart():
	get_tree().reload_current_scene()
	pass
	
func shoot():
	if !can_shoot:
		return
	can_shoot = false
	animated_sprite_2d.play("shoot")
	shoot_sound.play()
	if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("kill"):
		ray_cast_3d.get_collider().kill()
		pass
	pass

func shoot_anim_done():
	can_shoot = true
	pass
	
func arrow_direction():
	$CanvasLayer/Arrow.rotation_degrees = rotation_degrees.y
	$CanvasLayer/Arrow/right_arrow.modulate.a = velocity.x * 100 / 10 /100
	$CanvasLayer/Arrow/left_arrow.modulate.a = velocity.x * 100 / -10 /100
	$CanvasLayer/Arrow/down_arrow.modulate.a = velocity.z * 100 / 10 /100
	$CanvasLayer/Arrow/up_arrow.modulate.a = velocity.z * 100 / -10 /100
	pass

func kill():
	dead = true
	$CanvasLayer/DeathScreen.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pass
