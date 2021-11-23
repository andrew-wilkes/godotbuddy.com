extends Node

const DATA_FILE = "res://classes.dat"

var classes = {}

func get_classes():
	var t = OS.get_system_time_msecs()
	var data: PoolStringArray = get_file_content(DATA_FILE).split("\n")
	var i = 0
	while i < data.size():
		classes[data[i + 1]] = get_xml(data[i], data[i + 2])
		i += 3
	print(OS.get_system_time_msecs() - t)
	pass


func get_xml(buffer_size, encoded_string: String) -> PoolByteArray:
	var bytes = PoolByteArray([])
	var i = 0
	while i < encoded_string.length():
		var hex = "0x" + encoded_string.substr(i, 2)
		bytes.append(hex.hex_to_int())
		i += 2
	return bytes.decompress(buffer_size, File.COMPRESSION_DEFLATE) #.get_string_from_ascii()


func get_class_info(xml):
	var parser = XMLParser.new()
	if parser.open_buffer(xml) == OK:
		pass


func get_file_content(path) -> String:
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content
