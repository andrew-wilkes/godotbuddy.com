extends Node

const DATA_FILE = "res://classes.dat"
const SETTINGS_FILE_NAME = "user://settings.res"

var classes = {}
var settings: Settings

func _ready():
	load_classes()
	settings = load_settings()
	if settings.class_list.empty():
		settings.class_list = Data.classes.keys()
		settings.class_list.sort()
	pass


func get_class_info(xml):
	var parser = XMLParser.new()
	if parser.open_buffer(xml) == OK:
		pass


# Add class info to dictionary
func load_classes():
	# var t = OS.get_system_time_msecs()
	var data: PoolStringArray = get_file_content(DATA_FILE).split("\n")
	var i = 0
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
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content


func load_settings(file_name = SETTINGS_FILE_NAME):
	var _settings = Settings.new()
	if ResourceLoader.exists(file_name):
		var data = ResourceLoader.load(file_name)
		if data is Settings: # Check that the data is valid
			_settings = data
	return _settings


func save_settings(_settings, file_name = SETTINGS_FILE_NAME):
	assert(ResourceSaver.save(file_name, _settings) == OK)
