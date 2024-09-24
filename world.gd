extends Node3D

@onready var hit_rect = $UI/HitRect
@onready var spawns = $Map/spawns
@onready var large_spawns = $Map/large_spawns
@onready var navigation_region = $Map/NavigationRegion3D
signal yes_score
@onready var crosshair = $UI/Crosshair
@onready var crosshair_hit = $UI/Crosshairhit
var good_cross = false

var enemy = load("res://models/small_enemy.tscn")
var large_enemy = load ("res://evil_enemy_large_to_slystroyer.tscn")
var instance



func _ready():
	randomize()
	crosshair.visible = false
	crosshair.position.x = get_viewport().size.x / 2 - (-32)
	crosshair.position.y = get_viewport().size.y / 2 - (-32)
	crosshair_hit.position.x = get_viewport().size.x / 2 - (-32)
	crosshair_hit.position.y = get_viewport().size.y / 2 - (-32)
		
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_player_player_hit():
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)
	

func _on_enemy_spawn_timer_timeout():
	var spawn_point = _get_random_child(spawns).global_position
	instance = enemy.instantiate()
	instance.position = spawn_point
	instance.enemy_hit.connect(_on_enemy_hit)
	instance.position.y += 6
	navigation_region.add_child(instance)


func _on_enemy_hit():
	if good_cross:
		crosshair_hit.visible = true
		emit_signal("yes_score")
		await get_tree().create_timer(0.9).timeout
		crosshair_hit.visible = false
	else:
		emit_signal("yes_score")
	
	


func _on_small_enemy_enemy_hit():
	if good_cross:
		crosshair_hit.visible = true
		await get_tree().create_timer(0.9).timeout
		crosshair_hit.visible = false
	




func _on_player_remove_cross():
	crosshair.visible = false
	good_cross = false


func _on_player_show_cross():
	crosshair.visible = true
	good_cross = true


func _on_large_enemy_spawn_timer_timeout():
	var spawn_point = _get_random_child(large_spawns).global_position
	instance = large_enemy.instantiate()
	instance.position = spawn_point
	instance.large_enemy_hit.connect(_on_evil_enemy_large_to_slystroyer_large_enemy_hit)
	instance.position.y += 6
	navigation_region.add_child(instance)


func _on_evil_enemy_large_to_slystroyer_large_enemy_hit():
	if good_cross:
		crosshair_hit.visible = true
		emit_signal("yes_score")
		await get_tree().create_timer(0.9).timeout
		crosshair_hit.visible = false
	else:
		emit_signal("yes_score")
