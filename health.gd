extends Label

var health = 3

func _process(_delta):
	self.text = "%d" % health

func _on_player_player_hit():
	health -= 1
