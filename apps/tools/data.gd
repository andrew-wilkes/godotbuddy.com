extends Node

const DATA_FILE = "../desktop/classes.dat"

var classes = {}
var regex


func _ready():
	load_classes()


# Add class info to dictionary
func load_classes():
	# var t = OS.get_system_time_msecs()
	var data: PoolStringArray = get_file_content(DATA_FILE).split("\n")
	var i = 0
	if data.size() > 2:
		while i < data.size():
			classes[data[i + 1]] = get_xml(data[i], data[i + 2])
			i += 3
	# print(OS.get_system_time_msecs() - t)


func get_xml(buffer_size, encoded_string: String) -> PoolByteArray:
	var bytes = PoolByteArray([])
	var i = 0
	while i < encoded_string.length():
		var hex = "0x" + encoded_string.substr(i, 2)
		bytes.append(hex.hex_to_int())
		i += 2
	return bytes.decompress(buffer_size, File.COMPRESSION_DEFLATE) #.get_string_from_ascii()


func get_file_content(path) -> String:
	var content = ""
	var file = File.new()
	if file.open(path, File.READ) == OK:
		content = file.get_as_text()
		file.close()
	return content
