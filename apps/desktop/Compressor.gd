extends Control

const FOLDER = "/home/andrew/dev/websites/godotbuddy.com/data/godot-3.4/doc/classes/"
const DATA_FILE = "res://classes.dat"

var class_info = {}

func _ready():
	compress_files()


func compress_files():
	var files = get_file_list(FOLDER)
	var data = PoolStringArray([])
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
