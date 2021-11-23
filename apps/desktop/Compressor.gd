extends Control

const FOLDER = "/home/andrew/dev/websites/godotbuddy.com/data/godot-3.4/doc/classes/"
const DATA_FILE = "res://classes.dat"

func _ready():
	compress_files()


func load_data():
	var data: PoolStringArray = get_file_content(DATA_FILE).split("\n")


func get_xml(buffer_size, encoded_string):
	var bytes: PoolByteArray
	var i = 0
	while i < bytes.size():
		var hex = "0x" + encoded_string[i] + encoded_string[i + 1]
		bytes.append(hex.hex_to_int())
		i += 2
	return bytes.decompress(buffer_size)


func compress_files():
	var files = get_file_list(FOLDER)
	var data: PoolStringArray
	for file_name in files:
		var xml = get_file_bytes(FOLDER + file_name)
		data.append(String(xml.size())) # Buffer size
		data.append(file_name.get_basename()) # Class name
		data.append(xml.compress(File.COMPRESSION_DEFLATE).hex_encode())
	save(data.join("\n"))


func save(content):
	var file = File.new()
	file.open(DATA_FILE, File.WRITE)
	file.store_string(content)
	file.close()


func get_file_bytes(path) -> PoolByteArray:
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_buffer(file.get_len())
	file.close()
	return content


func get_file_content(path) -> String:
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_buffer(file.get_len())
	file.close()
	return content


func get_file_list(path):
	var files = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				files.append(file_name)
			file_name = dir.get_next()
		return files
	else:
		print("An error occurred when trying to access the path.")
