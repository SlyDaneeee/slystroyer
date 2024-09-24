extends Control

@onready var over_sound = $ovar_game

# Called when the node enters the scene tree for the first time.
func _ready():
	over_sound.play()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

