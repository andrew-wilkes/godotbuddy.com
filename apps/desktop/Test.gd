extends Control

func _ready():
	# test_class_details_get_info()
	pass


func test_class_details_get_info():
	for cname in Data.classes.keys():
		var info = JSON.print($ClassDetails.get_info(cname), "\t")
		save(info, "../../data/temp/" + cname + ".txt")


func save(content, file_name):
	var file = File.new()
	file.open(file_name, File.WRITE)
	file.store_string(content)
	file.close()
