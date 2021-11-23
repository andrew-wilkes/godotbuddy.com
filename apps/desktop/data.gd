extends Node

const DATA_PATH = "/home/andrew/dev/websites/godotbuddy.com/data/godot-3.4/doc/classes"

var classes = {}

func _init():
	get_classes()


func get_classes():
	var parser = XMLParser.new()
	var error = parser.open(DATA_PATH)
	if error != OK:
		print("Error opening XML file ", error)
		return
