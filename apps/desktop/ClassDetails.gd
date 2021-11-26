extends Control

enum { RAW, FORMATTED }

func _ready():
	var info = get_info("AABB")
	pass


func get_info(cname):
	var info = {}
	var node_name = ""
	var group_name = ""
	var member_name = ""
	var text_target
	var text_node_name
	var text_mode
	var parser = XMLParser.new()
	if parser.open_buffer(Data.classes[cname]) == OK:
		while true:
			if parser.read() != OK:
				return info
			match parser.get_node_type():
				parser.NODE_ELEMENT:
					node_name = parser.get_node_name()
					match node_name:
						"brief_description":
							text_mode = RAW
							text_target = info
							text_node_name = node_name
						"description":
							if group_name == "":
								text_mode = RAW
								text_target = info
								text_node_name = node_name
						"tutorials":
							info[node_name] = {}
							group_name = node_name
						"link":
							text_node_name = parser.get_named_attribute_value("title")
							text_target = info[group_name]
						"methods":
							info[node_name] = {}
							group_name = node_name
							text_node_name = "description"
						"method":
							member_name = parser.get_named_attribute_value("name")
							var method = {
								"qualifiers": parser.get_named_attribute_value_safe("qualifiers"),
								"args": {},
								"return_type": "",
							}
							info[group_name][member_name] = method
							text_target = info[group_name][member_name]
							text_mode = RAW
						"return":
							info[group_name][member_name]["return_type"] = parser.get_named_attribute_value("type")
						"argument":
							var keys = ["index", "type", "default"]
							member_name = add_member(parser, info, group_name, keys)
						"members":
							info[node_name] = {}
							group_name = node_name
						"member":
							var keys = ["type", "setter", "getter", "default"]
							member_name = add_member(parser, info, group_name, keys)
							text_target = info[group_name][member_name]
							text_mode = RAW
						"signals":
							info[node_name] = {}
							group_name = node_name
						"signal":
							member_name = parser.get_named_attribute_value("name")
							var asignal = {
								"args": {},
							}
							info[group_name][member_name] = asignal
							text_target = info[group_name][member_name]
							text_mode = RAW
						"constants":
							info[node_name] = {}
							group_name = node_name
						"constant":
							var keys = ["value", "enum"]
							member_name = add_member(parser, info, group_name, keys)
							text_target = info[group_name][member_name]
							text_mode = RAW
				parser.NODE_TEXT:
					if text_target != null:
						var txt = get_node_text(parser.get_node_data())
						if text_mode == FORMATTED:
							txt = format_text(txt)
						text_target[text_node_name] = txt
						text_target = null


func add_member(parser: XMLParser, info: Dictionary, group_name, keys: Array) -> String:
	var member_name = parser.get_named_attribute_value("name")
	var member = {}
	for key in keys:
		member[key] = parser.get_named_attribute_value_safe(key)
	info[group_name][member_name] = member
	return member_name


func get_node_text(txt: String):
	return txt.replace("\n", "").dedent()


func format_text(txt):
	return txt.replace("[", "").replace("]", "")
