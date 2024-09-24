extends CharacterBody3D


var player = null
var state_machine
var health = 2
var already_being_harmed = true
signal enemy_hit
signal growling
signal one_score
const SPEED = 3.5
const ATTACK_RANGE = 1.3

@export var player_path := "/root/World/Map/Player"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var biting_sound = $biting
@onready var growling_sound = $growling
@onready var laser_exlosion = $laser_death
# Called when the node enters the scene tree for the first time.


func _ready():
	player = get_node(player_path)
	state_machine= anim_tree.get("parameters/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"walking 2":
			#navigation
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z ), Vector3.UP)
	
	
	

	
	
	
	
	#conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/walk", !_target_in_range())
	
	anim_tree.get("parameters/playback")
	move_and_slide()
 
func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
	
func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0 and already_being_harmed:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)
		
		
	




func _on_area_3d_body_part_hit(dam):
	health -= dam
	emit_signal("enemy_hit")
	if health <= 0:
		laser_exlosion.play()
		emit_signal("one_score")
		anim_tree.set("parameters/conditions/die", true)
		await get_tree().create_timer(4.0).timeout
		queue_free()



func _on_area_3d_2_body_part_hit(_dam):
	emit_signal("enemy_hit")

func _growling():
	growling_sound.play()
