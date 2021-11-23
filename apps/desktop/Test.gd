extends Control

func _init():
	Data.get_classes()
	Data.get_class_info(Data.classes.values()[0])

