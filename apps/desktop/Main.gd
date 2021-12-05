extends Control

func _ready():
	pass


func _on_ClassExplorer_pressed():
	var _e = get_tree().change_scene("res://ClassList.tscn")
