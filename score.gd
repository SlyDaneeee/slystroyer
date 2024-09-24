extends Label

var score = 0

func _process(_delta):
	self.text = "%d" % score


func _on_small_enemy_enemy_hit():
	score += 1



func _on_world_yes_score():
	score += 1


func _on_small_enemy_one_score():
	score += 1


func _on_small_enemy_4_one_score():
	score += 1
