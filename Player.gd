extends CharacterBody3D

var speed
const WALK_SPEED = 3.5
const SPRINT_SPEED= 7.0
const JUMP_VELOCITY = 6.5
const SENSITIVITY = 0.0026
const HIT_STAGGER = 6.0

#bob variables
const BOB_FREQ= 2.0
const BOB_AMP= 0.08
var t_bob= 0.0

#fov variables
const BASE_FOV= 75.0
const FOV_CHANGE= 1.5

#signal
signal player_hit


var gravity = 9.8

#bullets
var bullet = load("res://bullet.tscn")
var bullet_trail = load("res://BulletTrail.tscn")
var instance

#weapon switching
enum weapons {PISTOLS,AUTO}
var weapon = weapons.PISTOLS
var can_shoot = true

@onready var weapon_switching = $Head/Camera3D/WeaponSwitching
#Camera
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var attackingu = $biting_yeah
@onready var aim_ray = $Head/Camera3D/AimRay
@onready var aim_ray_end = $Head/Camera3D/AimRayEnd
@onready var switch = $Head/Camera3D/weapon_switching
@onready var click = $clicking
var healthi = 3
#Guns
@onready var gunshot = $Head/Camera3D/Gun_to_slystroyer/gunshot
@onready var gun_anim = $Head/Camera3D/Gun_to_slystroyer/AnimationPlayer
@onready var gun_barrel = $Head/Camera3D/Gun_to_slystroyer/RayCast3D
@onready var auto_anim = $Head/Camera3D/shotgun_to_slystroyer/AnimationPlayer
@onready var auto_barrel = $Head/Camera3D/shotgun_to_slystroyer/Meshes/barrel
@onready var shottygun = $Head/Camera3D/shotgun_to_slystroyer/shottygun
@onready var gammi = $game_over_soundi
@export_file("*.tscn") var scene
signal remove_cross
signal show_cross

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
	click.play()
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#handle sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	 
	 
	
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x=lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z=lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x=lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z=lerp(velocity.z, direction.z * speed, delta * 2.0)
	
	#head bob
	t_bob+= delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	if Input.is_action_pressed("leave"):
		pass
	
	
	#FOV
	var velocity_clamped=clamp(velocity.length (), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov= lerp(camera.fov, target_fov, delta * 8.0)
	
	#shooting
	if Input.is_action_pressed("shoot") and can_shoot:
		match weapon:
			weapons.PISTOLS:
				_shoot_pistols()
			weapons.AUTO:
				_shoot_auto()
		
	
	#weapon switching
	if Input.is_action_just_pressed("weapon_two") and weapon != weapons.AUTO:
		_raise_weapon(weapons.AUTO)
	if Input.is_action_just_pressed("weapon_one") and weapon != weapons.PISTOLS:
		_raise_weapon(weapons.PISTOLS)


	

	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func hit(dir):
	emit_signal("player_hit")
	velocity += dir * HIT_STAGGER


func _on_player_hit():
	healthi -= 1
	attackingu.play()
	if healthi <= 0:
		gammi.play()
		get_tree().change_scene_to_file("res://game_over_menu_enemy.tscn")
	
func _shoot_pistols():
	if !gun_anim.is_playing():
		gun_anim.play("shoot")
		gunshot.play()
		instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		instance.position.y += 6.75
		get_parent().add_child(instance)
		

func _shoot_auto():
	if !auto_anim.is_playing():
		auto_anim.play("shoot")
		shottygun.play()
		instance = bullet_trail.instantiate()
		if aim_ray.is_colliding():
			instance.init(auto_barrel.global_position, aim_ray.get_collision_point())
			get_parent().add_child(instance)
			if aim_ray.get_collider().is_in_group("enemy"):
				aim_ray.get_collider().hit()
				instance.trigger_particles(aim_ray.get_collision_point(), auto_barrel.global_position, true)
			else:
				instance.trigger_particles(aim_ray.get_collision_point(), auto_barrel.global_position, false)
		else:
			instance.init(auto_barrel.global_position, aim_ray_end.global_position)
			get_parent().add_child(instance)

func _lower_weapon():
	match weapon:
		weapons.AUTO:
			weapon_switching.play("LowerAuto")
			
		weapons.PISTOLS:
			weapon_switching.play("LowerPistols")
			



func _raise_weapon(new_weapon):
	can_shoot = false
	_lower_weapon()
	await get_tree().create_timer(0.3).timeout
	match new_weapon:
		weapons.AUTO:
			switch.play()
			weapon_switching.play_backwards("LowerAuto")
			emit_signal("show_cross")
		weapons.PISTOLS:
			switch.play()
			weapon_switching.play_backwards("LowerPistols")
			emit_signal("remove_cross")
	weapon = new_weapon
	can_shoot = true




func _on_small_enemy_4_one_score():
	pass # Replace with function body.


func _on_area_3d_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file.bind("res://game_over_menu_void.tscn").call_deferred()

	
	
