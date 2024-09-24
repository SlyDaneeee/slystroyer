extends Button
@onready var click = $"../../../clicking"
# Makes a file selector available in the Inspector, and
# stores the path of the selected file in the variable "scene".
@export_file("*.tscn") var scene

# When the user presses the button of the script
func _on_pressed():
	# Change to the selected scene
	get_tree().change_scene_to_file("res://world.tscn")

